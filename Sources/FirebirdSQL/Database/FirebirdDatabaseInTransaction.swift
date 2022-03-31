//
//  FirebirdDatabaseInTransaction.swift
//  
//
//  Created by ugo cottin on 30/03/2022.
//

import fbclient
import Logging

public struct FirebirdDatabaseInTransaction {
	
	public let database: FirebirdDatabase
	public let transaction: FirebirdTransaction
	
}

extension FirebirdDatabaseInTransaction: FirebirdDatabase {
	
	public var logger: Logger {
		self.database.logger
	}
	
	public var handle: isc_db_handle {
		self.database.handle
	}
	
	public func createStatement(_ query: String) -> FirebirdStatement {
		self.database.createStatement(query)
	}
	
	public func execute(_ statement: FirebirdStatement, transaction: FirebirdTransaction, logger: Logger) throws -> FirebirdQueryResult {
		try self.database.execute(statement, transaction: self.transaction, logger: self.logger)
	}
	
	public func withConnection<T>(_ closure: (FirebirdConnection) throws -> T) rethrows -> T {
		try self.database.withConnection(closure)
	}
	
	// MARK: - Query
	public func query(_ queryString: String, parameters: [Encodable]) throws -> FirebirdQuery {
		guard var cQueryString = queryString.cString(using: .utf8) else {
			throw FirebirdCustomError(reason: "Non UTF-8 encoded query string")
		}
		
		guard let cQueryStringLength = UInt16(exactly: cQueryString.count) else {
			throw FirebirdCustomError(reason: "Query string too long")
		}
		
		self.logger.debug("Preparing query on \(self)")
		
		let dialect = UInt16(SQL_DIALECT_V6)
		let database = self.database
		var statementHandle: isc_stmt_handle = .zero
		try withStatus { status in
			withUnsafePointer(to: database.handle) { handlePointer in
				let mutableHandle = UnsafeMutablePointer(mutating: handlePointer)
				assert(mutableHandle.hashValue == handlePointer.hashValue)
				return isc_dsql_allocate_statement(&status, mutableHandle, &statementHandle)
			}
			
		}
		
		let transaction = self.transaction
		try withStatus { status in
			isc_dsql_prepare(&status, &transaction.handle, &statementHandle, cQueryStringLength, &cQueryString, dialect, nil)
		}
		
		return FirebirdQuery(
			handle: statementHandle,
			transactionalDatabase: FirebirdDatabaseInTransaction(database: database, transaction: transaction),
			sql: queryString,
			dialect: dialect,
			allocationPool: FirebirdDefaultAllocationPoolSource())
	}
	
	// MARK: - Transaction
	public var inTransaction: Bool {
		true
	}
	
	public var transactionalDatabase: FirebirdDatabaseInTransaction? {
		self
	}
	
	public func startTransaction(parameters: FirebirdTransactionParameterBuffer?) throws -> FirebirdDatabase {
		try self.database.startTransaction(parameters: parameters)
	}
	
	public func commitTransaction() throws -> FirebirdDatabase {
		//self.transaction
		return self.database
	}
	
	public func rollbackTransaction() throws -> FirebirdDatabase {
		// rollback
		return self.database
	}
	
	
}

extension FirebirdDatabaseInTransaction: CustomStringConvertible {
	
	public var description: String {
		"[Database: \(self.database), Transaction: \(self.transaction)]"
	}
	
}
