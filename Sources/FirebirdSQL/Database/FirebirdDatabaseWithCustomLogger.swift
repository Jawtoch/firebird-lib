//
//  FirebirdDatabaseWithCustomLogger.swift
//  
//
//  Created by Ugo Cottin on 23/03/2022.
//

import Logging
import fbclient

internal struct FirebirdDatabaseWithCustomLogger {
	let database: FirebirdDatabase
	let logger: Logger
}

extension FirebirdDatabaseWithCustomLogger: FirebirdDatabase {
	var handle: isc_db_handle {
		self.database.handle
	}
	
	func createStatement(_ query: String) -> FirebirdStatement {
		self.database.createStatement(query)
	}
	
	func execute(_ statement: FirebirdStatement, transaction: FirebirdTransaction, logger: Logger) throws -> FirebirdQueryResult {
		return try self.database.execute(statement, transaction: transaction, logger: logger)
	}
	
	func withConnection<T>(_ closure: (FirebirdConnection) throws -> T) rethrows -> T {
		try self.database.withConnection(closure)
	}
	
	// MARK: - Query
	func query(_ queryString: String, parameters: [Encodable]) throws -> FirebirdQuery {
		try self.database.query(queryString, parameters: parameters)
	}
	
	// MARK: - Transaction
	var inTransaction: Bool {
		self.database.inTransaction
	}
	
	var transactionalDatabase: FirebirdDatabaseInTransaction? {
		self.database.transactionalDatabase
	}
	
	func startTransaction(parameters: FirebirdTransactionParameterBuffer?) throws -> FirebirdDatabase {
		try self.database.startTransaction(parameters: parameters)
			.logging(to: self.logger)
	}
	
	func commitTransaction() throws -> FirebirdDatabase {
		try self.database.commitTransaction()
			.logging(to: self.logger)
	}
	
	func rollbackTransaction() throws -> FirebirdDatabase {
		try self.database.rollbackTransaction()
			.logging(to: self.logger)
	}
}

extension FirebirdDatabaseWithCustomLogger: CustomStringConvertible {
	
	var description: String {
		"\(self.database)"
	}
	
}
