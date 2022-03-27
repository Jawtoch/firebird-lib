//
//  FirebirdConnection.swift
//  
//
//  Created by Ugo Cottin on 23/03/2022.
//

import Logging
import fbclient

public class FirebirdConnection {
	
	public let logger: Logger
	
	var handle: isc_db_handle
	
	public var isClosed: Bool {
		self.handle <= 0
	}
	
	public static func connect(to host: String, port: UInt16 = 3050, database: String, parameters: FirebirdConnectionParameterBuffer, logger: Logger) async throws -> FirebirdConnection {
		let databaseUrl = "\(host)/\(port):\(database)"
		
		logger.debug("Opening new connection to \(databaseUrl)")
		
		var status = FirebirdVectorError.vector
		var handle: isc_stmt_handle = .zero
		
		var parametersBuffer = parameters.parameters.flatMap { $0.rawBytes }
		
		try parametersBuffer.withUnsafeMutableBufferPointer { bufferPointer in
			let bufferBaseAddress = bufferPointer.baseAddress
			guard let bufferLength = Int16(exactly: bufferPointer.count) else {
				throw FirebirdCustomError(reason: "Buffer too large")
			}
			
			try databaseUrl.withCString { cDatabaseUrl in
				if isc_attach_database(&status, Int16(databaseUrl.count), cDatabaseUrl, &handle, bufferLength, bufferBaseAddress) > 0 {
					throw FirebirdVectorError(from: status)
				}
			}
		}
			
		return FirebirdConnection(handle: handle, logger: logger)
	}
	
	init(handle: isc_db_handle, logger: Logger) {
		self.logger = logger
		self.handle = handle
	}
	
	func requestInformations(_ informations: [DatabaseInformation], logger: Logger) throws {
		logger.debug("Requesting \(informations.count) information(s) for connection \(self)")
		
		let requestBuffer = informations.map { $0.rawValue }
		guard let requestBufferLength = Int16(exactly: requestBuffer.count) else {
			throw FirebirdCustomError(reason: "Too many requested informations")
		}
		
		let resultBufferLength: Int16 = 40
		var resultBuffer = Array<ISC_SCHAR>(repeating: .zero, count: Int(resultBufferLength))
		
		try requestBuffer.withUnsafeBufferPointer { requestBufferPointer in
			try resultBuffer.withUnsafeMutableBufferPointer { resultBufferPointer in
				try withStatus { status in
					isc_database_info(&status, &self.handle, requestBufferLength, requestBufferPointer.baseAddress, resultBufferLength, resultBufferPointer.baseAddress)
				}
			}
		}
		
		var requestedInformations: [DatabaseInformation.RawValue: ISC_LONG] = [:]
		resultBuffer.withUnsafeMutableBufferPointer { resultBufferPointer in
			
			guard let bufferAddress = resultBufferPointer.baseAddress else {
				return
			}
			
			var index = 0
			
			while bufferAddress.advanced(by: index).pointee != isc_info_end {
				let item = bufferAddress.advanced(by: index).pointee
				
				let length = isc_vax_integer(bufferAddress.advanced(by: index + 1), 2)
				let itemValue = isc_vax_integer(bufferAddress.advanced(by: index + 3), Int16(length))
				
				index += Int(length) + 3
				
				logger.debug("Request for information \(item) returned value \(itemValue) for connection \(self)")
				requestedInformations[db_info_types.RawValue(item)] = itemValue
			}
			
		}
		
		print(requestedInformations)
	}
}

extension FirebirdConnection: Database {
	
	public func createStatement(_ query: String) -> Statement {
		var status = FirebirdVectorError.vector
		var statementHandle: isc_stmt_handle = .zero
		
		isc_dsql_allocate_statement(&status, &self.handle, &statementHandle)
		
		return Statement(handle: statementHandle, database: self, query: query, dialect: UInt16(SQL_DIALECT_V6))
	}
		
	public func execute(_ statement: Statement, transaction: Transaction, logger: Logger) throws -> QueryResult {
		try statement.prepare(transaction: transaction, logger: logger)
		try statement.describe(logger: logger)
		let result = try statement.execute(transaction: transaction, cursorName: "dyn_cursor", logger: logger)
		try statement.free(.close, logger: logger)
		
		return result
	}
		
	public func withConnection<T>(_ closure: (FirebirdConnection) throws -> T) rethrows -> T {
		try closure(self)
	}
	
	public func startTransaction(parameters: TransactionParameterBuffer) throws -> Transaction {
		var status = FirebirdVectorError.vector
		var transactionHandle: isc_tr_handle = .zero
		
		let parametersBuffer = parameters.parameters.flatMap { $0.rawBytes }
		
		try parametersBuffer.withUnsafeBufferPointer { bufferPointer in
			try withUnsafeMutablePointer(to: &self.handle) { databaseHandle in
				guard let bufferLength = Int(exactly: bufferPointer.count) else {
					throw FirebirdCustomError(reason: "Buffer too large")
				}
				
				let block = TransactionExistenceBlock(
					database: databaseHandle,
					count: bufferLength,
					parameters: bufferPointer)
				
				var blocks = [ block ]
				guard let blocksCount = Int16(exactly: blocks.count) else {
					throw FirebirdCustomError(reason: "Blocks count too big")
				}
				
				try blocks.withUnsafeMutableBytes { blocksPointer in
					guard let blocksAddress = blocksPointer.baseAddress else {
						fatalError()
					}
					
					if isc_start_multiple(&status, &transactionHandle, blocksCount, blocksAddress) > 0 {
						throw FirebirdVectorError(from: status)
					}
				}
			}
		}
		
		return Transaction(handle: transactionHandle)
	}
}

extension FirebirdConnection: CustomStringConvertible {
	
	public var description: String {
		"\(self.handle)"
	}
	
}
