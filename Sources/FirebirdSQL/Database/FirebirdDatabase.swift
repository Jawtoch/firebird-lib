//
//  FirebirdDatabase.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import Logging

public protocol FirebirdDatabase {
	
	var logger: Logger { get }
	
	func createStatement(_ query: String) -> FirebirdStatement
	
	func execute(_ statement: FirebirdStatement, transaction: FirebirdTransaction, logger: Logger) throws -> FirebirdQueryResult
	
	func withConnection<T>(_ closure: (FirebirdConnection) throws -> T) rethrows -> T
	
	func startTransaction(parameters: FirebirdTransactionParameterBuffer) throws -> FirebirdTransaction
}

extension FirebirdDatabase {
	
	public func logging(to logger: Logger) -> FirebirdDatabase {
		FirebirdDatabaseWithCustomLogger(database: self, logger: logger)
	}
	
}
