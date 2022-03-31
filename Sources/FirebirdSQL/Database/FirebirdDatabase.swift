//
//  FirebirdDatabase.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient
import Logging

public protocol FirebirdDatabase {
	
	var logger: Logger { get }
	
	var handle: isc_db_handle { get }
	
	func createStatement(_ query: String) -> FirebirdStatement
	
	func execute(_ statement: FirebirdStatement, transaction: FirebirdTransaction, logger: Logger) throws -> FirebirdQueryResult
	
	func withConnection<T>(_ closure: (FirebirdConnection) throws -> T) rethrows -> T
	
	// MARK: - Query
	func query(_ queryString: String, parameters: [Encodable]) throws -> FirebirdQuery
	
	// MARK: - Transaction
	var inTransaction: Bool { get }
	
	var transactionalDatabase: FirebirdDatabaseInTransaction? { get }
	
	func startTransaction(parameters: FirebirdTransactionParameterBuffer?) throws -> FirebirdDatabase
	
	func commitTransaction() throws -> FirebirdDatabase
	
	func rollbackTransaction() throws -> FirebirdDatabase
	
}

extension FirebirdDatabase {
	
	public func logging(to logger: Logger) -> FirebirdDatabase {
		FirebirdDatabaseWithCustomLogger(database: self, logger: logger)
	}
	
}
