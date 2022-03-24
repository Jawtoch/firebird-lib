//
//  Connection.swift
//  
//
//  Created by Ugo Cottin on 23/03/2022.
//

import Logging
import fbclient

func withStatus(_ closure: (inout [ISC_STATUS]) throws -> ISC_STATUS) throws {
	var status = FirebirdVectorError.vector
	if try closure(&status) > 0 {
		throw FirebirdVectorError(from: status)
	}
}

public class Connection {
	
	public let logger: Logger
	
	var handle: isc_db_handle
	
	public var isClosed: Bool {
		self.handle <= 0
	}
	
	public static func connect(to host: String, port: UInt16 = 3050, database: String, parameters: ConnectionParameterBuffer, logger: Logger) async throws -> Connection {
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
			
		return Connection(handle: handle, logger: logger)
	}
	
	init(handle: isc_db_handle, logger: Logger) {
		self.logger = logger
		self.handle = handle
	}
}

extension Connection: Database {
	
	public func createStatement(_ query: String) -> Statement {
		var status = FirebirdVectorError.vector
		var statementHandle: isc_stmt_handle = .zero
		
		isc_dsql_allocate_statement(&status, &self.handle, &statementHandle)
		
		return Statement(handle: statementHandle, database: self, query: query, dialect: UInt16(SQL_DIALECT_V6))
	}
		
	public func execute(_ statement: Statement, transaction: Transaction, logger: Logger) async throws {
		try await statement.prepare(transaction: transaction, logger: logger)
		try statement.describe(logger: logger)
		try statement.execute(transaction: transaction, cursorName: "dyn_cursor", logger: logger)
	}
		
	public func withConnection<T>(_ closure: (Connection) async throws -> T) async rethrows -> T {
		try await closure(self)
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
