//
//  Database.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import Logging

public protocol Database {
	
	var logger: Logger { get }
	
	func createStatement(_ query: String) -> Statement
	
	func execute(_ statement: Statement, transaction: Transaction, logger: Logger) throws -> QueryResult
	
	func withConnection<T>(_ closure: (Connection) throws -> T) rethrows -> T
	
	func startTransaction(parameters: TransactionParameterBuffer) throws -> Transaction
}

extension Database {
	
	public func logging(to logger: Logger) -> Database {
		DatabaseWithCustomLogger(database: self, logger: logger)
	}
	
}
