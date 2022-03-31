//
//  FirebirdQuery.swift
//  
//
//  Created by ugo cottin on 30/03/2022.
//

import fbclient
import Logging

public class FirebirdQuery {
	
	public var handle: isc_stmt_handle
	
	public let transactionalDatabase: FirebirdDatabaseInTransaction
	
	public let sql: String
	
	public var dialect: UInt16
	
	private var inputDescriptorArea: FirebirdDescriptorArea?
	
	private var outputDescriptorArea: FirebirdDescriptorArea?
	
	private let allocationPool: FirebirdAllocationPoolSource
	
	public var logger: Logger {
		self.transactionalDatabase.logger
	}
	
	init(handle: isc_stmt_handle, transactionalDatabase: FirebirdDatabaseInTransaction, sql: String, dialect: UInt16, inputDescriptorArea: FirebirdDescriptorArea? = nil, outputDescriptorArea: FirebirdDescriptorArea? = nil, allocationPool: FirebirdAllocationPoolSource) {
		self.handle = handle
		self.transactionalDatabase = transactionalDatabase
		self.sql = sql
		self.dialect = dialect
		self.inputDescriptorArea = inputDescriptorArea
		self.outputDescriptorArea = outputDescriptorArea
		self.allocationPool = allocationPool
	}
	
	public func describe() throws -> FirebirdQueryWithDescription {
		logger.debug("Describing \(self)")
		
		if let inputDescriptorArea = self.inputDescriptorArea {
			logger.debug("Input descriptor area already exist for \(self), deallocating it")
			inputDescriptorArea.deallocate()
			self.inputDescriptorArea = nil
		}
		
		if let outputDescriptorArea = self.outputDescriptorArea {
			logger.debug("Output descriptor area already exist for \(self), deallocating it")
			outputDescriptorArea.deallocate()
			self.outputDescriptorArea = nil
		}
		
		let inputDescriptorArea = try self.describeInput(logger: logger)
		let outputDescriptorArea = try self.describeOutput(logger: logger)
		
		return FirebirdQueryWithDescription(
			inputDescription: inputDescriptorArea,
			outputDescriptorArea: outputDescriptorArea,
			allocationPool: self.allocationPool,
			_query: self)
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

extension FirebirdQuery: CustomStringConvertible {
	
	public var description: String {
		"Query(handle: \(self.handle), database: \(self.transactionalDatabase)"
	}
	
}


public struct FirebirdQueryWithDescription {
	let inputDescription: FirebirdDescriptorArea?
	let outputDescriptorArea: FirebirdDescriptorArea
	let allocationPool: FirebirdAllocationPoolSource
	
	let _query: FirebirdQuery
	
	var logger: Logger {
		self._query.logger
	}
	
	func execute() throws -> [FirebirdRow] {
		self.logger.debug("Executing \(self)")
		
		try withStatus { status in
			isc_dsql_execute(&status, &self._query.transactionalDatabase.transaction.handle, &self._query.handle, 1, outputDescriptorArea.handle)
		}
		
		self.logger.debug("Opening cursor for \(self)")
		
		try withStatus { status in
			isc_dsql_set_cursor_name(&status, &self._query.handle, "dyn_cursor", 0)
		}
		
		var rows: [FirebirdRow] = []
		
		try withStatus { status in
			let fetchStatus: ISC_STATUS = 0
			logger.debug("Fetching results for statement \(self)")
			var index = 0
			while case fetchStatus = isc_dsql_fetch(&status, &self._query.handle, 1, self.outputDescriptorArea.handle), fetchStatus == 0 {
				
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
		
		return rows
	}
}
