//
//  FirebirdStatement.swift
//  
//
//  Created by ugo cottin on 03/03/2022.
//

import fbclient
import Logging

public class FirebirdStatement {

	public var handle: isc_stmt_handle
	
	public let query: String
	
	public var dialect: UInt16
	
	private var inputDescriptorArea: FirebirdDescriptorArea?
	
	private var outputDescriptorArea: FirebirdDescriptorArea?
	
	private let allocationPool: FirebirdAllocationPoolSource
	
	public init(handle: isc_stmt_handle, database: FirebirdDatabase, query: String, dialect: UInt16) {
		self.handle = handle
		self.query = query
		self.dialect = dialect
		self.inputDescriptorArea = nil
		self.outputDescriptorArea = nil
		self.allocationPool = FirebirdDefaultAllocationPoolSource()
	}
	
	public func prepare(transaction: FirebirdTransaction, logger: Logger) throws {
		try self.query.withCString { queryStringPointer in
			guard let queryLength = UInt16(exactly: query.count) else {
				throw FirebirdCustomError(reason: "Wrong query string size")
			}
			
			logger.debug("Preparing statement \(self)")
			try withStatus { status in
				isc_dsql_prepare(&status, &transaction.handle, &self.handle, queryLength, queryStringPointer, self.dialect, nil)
			}
		}
	}
	
	public func describe(logger: Logger) throws {
		logger.debug("Describing statement \(self)")
		
		if let inputDescriptorArea = self.inputDescriptorArea {
			logger.debug("Input descriptor area already exist for statement \(self), deallocating it")
			inputDescriptorArea.deallocate()
			self.inputDescriptorArea = nil
		}
		
		if let outputDescriptorArea = self.outputDescriptorArea {
			logger.debug("Output descriptor area already exist for statement \(self), deallocating it")
			outputDescriptorArea.deallocate()
			self.outputDescriptorArea = nil
		}
		
		//self.inputDescriptorArea = try self.describeInput(logger: logger)
		self.outputDescriptorArea = try self.describeOutput(logger: logger)
	}
	
	public func execute(transaction: FirebirdTransaction, cursorName: String, logger: Logger) throws -> FirebirdQueryResult {
		logger.debug("Executing statement \(self)")
		
		guard let outputDescriptorArea = outputDescriptorArea else {
			fatalError()
		}

		
		try withStatus { status in
			isc_dsql_execute(&status, &transaction.handle, &self.handle, 1, outputDescriptorArea.handle)
			// isc_dsql_execute2(&status, &transaction.handle, &self.handle, 1, self.inputDescriptorArea?.handle, outputDescriptorArea.handle)
		}
		
		logger.debug("Opening cursor '\(cursorName)' for statement \(self)")
		try withStatus { status in
			isc_dsql_set_cursor_name(&status, &self.handle, cursorName, 0)
		}
		
		var rows: [FirebirdRow] = []
		
		try withStatus { status in
			let fetchStatus: ISC_STATUS = 0
			logger.debug("Fetching results for statement \(self)")
			var index = 0
			while case fetchStatus = isc_dsql_fetch(&status, &self.handle, 1, outputDescriptorArea.handle), fetchStatus == 0 {
				
				var columns: [FirebirdColumn] = []
				for variable in outputDescriptorArea {
					let context = FirebirdCodingContext(
						dataType: variable.type,
						scale: variable.scale,
						size: variable.maximumSize)
					let column = FirebirdColumn(name: variable.name, context: context, data: variable.data)
					columns.append(column)
				}
				
				let row = FirebirdRow(index: index, columns: columns)
				rows.append(row)
				index += 1
			}
			
			return 0
		}
		
		logger.debug("\(rows.count) rows fetched for statement \(self)")
		
		return FirebirdQueryResult(rows: rows)
	}
	
	public func free(_ option: FirebirdStatementFreeOption = .close, logger: Logger) throws {
		logger.debug("Freeing statement \(self) with option \(option)")
		try withStatus { status in
			isc_dsql_free_statement(&status, &self.handle, option.rawValue)
		}
		
		self.allocationPool.release(logger: logger)
	}
	
	private func describeInput(count: Int16 = 10, logger: Logger) throws -> FirebirdDescriptorArea {
		let descriptorArea = FirebirdDescriptorArea(capacity: count, version: Int16(SQLDA_VERSION1))
		
		logger.debug("Allocating input descriptor area of size \(count) for statement \(self)")
		try withStatus { status in
			isc_dsql_describe_bind(&status, &self.handle, 1, descriptorArea.handle)
		}
		
		if !descriptorArea.isLargeEnough {
			logger.debug("Input descriptor area of size \(descriptorArea.count) for statement \(self) is not large enough")
			let count = descriptorArea.parametersCount
			
			logger.debug("Deallocating input descriptor area for statement \(self)")
			descriptorArea.deallocate()
			return try self.describeInput(count: count, logger: logger)
		}
		
		return descriptorArea
	}
	
	private func describeOutput(count: Int16 = 10, logger: Logger) throws -> FirebirdDescriptorArea {
		let descriptorArea = FirebirdDescriptorArea(capacity: count, version: Int16(SQLDA_VERSION1))
		
		logger.debug("Allocating output descriptor area of size \(count) for statement \(self)")
		try withStatus { status in
			isc_dsql_describe(&status, &self.handle, 1, descriptorArea.handle)
		}
		
		if !descriptorArea.isLargeEnough {
			logger.debug("Output descriptor area of size \(descriptorArea.count) for statement \(self) is not large enough")
			let count = descriptorArea.parametersCount
			
			logger.debug("Deallocating output descriptor area for statement \(self)")
			descriptorArea.deallocate()
			return try self.describeOutput(count: count, logger: logger)
		}
		
		for variable in descriptorArea {
			self.allocationPool.makeAllocation(for: variable, logger: logger)
		}
		
		return descriptorArea
	}
}

extension FirebirdStatement: CustomStringConvertible {
	
	public var description: String {
		"\(self.handle)"
	}
	
}
