//
//  DatabaseWithCustomLogger.swift
//  
//
//  Created by Ugo Cottin on 23/03/2022.
//

import Logging

internal struct DatabaseWithCustomLogger {
	let database: Database
	let logger: Logger
}

extension DatabaseWithCustomLogger: Database {
	func createStatement(_ query: String) -> Statement {
		self.database.createStatement(query)
	}
	
	func execute(_ statement: Statement, transaction: Transaction, logger: Logger) async throws {
		try await self.database.execute(statement, transaction: transaction, logger: logger)
	}
	
	func withConnection<T>(_ closure: (Connection) async throws -> T) async rethrows -> T {
		try await self.database.withConnection(closure)
	}

	func startTransaction(parameters: TransactionParameterBuffer) throws -> Transaction {
		try self.database.startTransaction(parameters: parameters)
	}
}
