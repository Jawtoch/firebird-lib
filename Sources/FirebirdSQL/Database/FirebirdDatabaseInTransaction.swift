//
//  FirebirdDatabaseInTransaction.swift
//  
//
//  Created by ugo cottin on 30/03/2022.
//

import Logging

struct FirebirdDatabaseInTransaction {
	
	let database: FirebirdDatabase
	let transaction: FirebirdTransaction
	
}

extension FirebirdDatabaseInTransaction: FirebirdDatabase {
	var logger: Logger {
		self.database.logger
	}
	
	func createStatement(_ query: String) -> FirebirdStatement {
		self.database.createStatement(query)
	}
	
	func execute(_ statement: FirebirdStatement, transaction: FirebirdTransaction, logger: Logger) throws -> FirebirdQueryResult {
		try self.database.execute(statement, transaction: self.transaction, logger: self.logger)
	}
	
	func withConnection<T>(_ closure: (FirebirdConnection) throws -> T) rethrows -> T {
		try self.database.withConnection(closure)
	}
	
	var inTransaction: Bool {
		true
	}
	
	func startTransaction(parameters: FirebirdTransactionParameterBuffer) throws -> FirebirdDatabase {
		try self.database.startTransaction(parameters: parameters)
	}
	
	func commitTransaction() throws -> FirebirdDatabase {
		//self.transaction
		return self.database
	}
	
	func rollbackTransaction() throws -> FirebirdDatabase {
		// rollback
		return self.database
	}
	
	
}
