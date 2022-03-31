//
//  FirebirdSQLTests.swift
//  
//
//  Created by ugo cottin on 03/03/2022.
//

import XCTest
@testable import FirebirdSQL
import Logging

class FirebirdSQLTests: XCTestCase {

	var logger: Logger {
		var logger = Logger(label: "test.firebirdsql")
		logger.logLevel = .debug
		return logger
	}
	
	func connect() async throws -> FirebirdConnection {
		var connectionParameters = FirebirdConnectionParameterBuffer()
		
		connectionParameters.add(parameter: FirebirdVersion1ConnectionParameter())
		connectionParameters.add(parameter: FirebirdDialectConnectionParameter(.v6))
		connectionParameters.add(parameter: FirebirdUsernameConnectionParameter("SYSDBA"))
		connectionParameters.add(parameter: FirebirdPasswordConnectionParameter("SMETHING"))
		
		return try await FirebirdConnection.connect(to: "127.0.0.1", database: "employee", parameters: connectionParameters, logger: self.logger)
	}
	
	func testQuery() async throws {
		let connection = try await self.connect()
		XCTAssertFalse(connection.isClosed)
		
		let transationalDatabase = try connection.startTransaction(parameters: .none)
		
		let query = try transationalDatabase.query("SELECT phone_ext FROM employee", parameters: [])
		let describedQuery = try query.describe()
		let rows = try describedQuery.execute()
		
		
		let decoder = FirebirdDecoder()
		for row in rows {
			for column in row.columns {
				let value = try decoder.decode(String.self, from: column.data, context: column.context)
				print(row.index, column.name, value)
			}
		}
	}
	
	func testConnection() async throws {
		/*do {
			var logger = Logger(label: "test.firebirdsql")
			logger.logLevel = .debug
			var connectionParameters = FirebirdConnectionParameterBuffer()
			
			connectionParameters.add(parameter: FirebirdVersion1ConnectionParameter())
			connectionParameters.add(parameter: FirebirdDialectConnectionParameter(.v6))
			connectionParameters.add(parameter: FirebirdUsernameConnectionParameter("SYSDBA"))
			connectionParameters.add(parameter: FirebirdPasswordConnectionParameter("SMETHING"))
			
			let connection = try await FirebirdConnection.connect(to: "127.0.0.1", database: "employee", parameters: connectionParameters, logger: logger)
			XCTAssertFalse(connection.isClosed)
			
			try connection.requestInformations([
				FirebirdODSVersionDatabaseInformation(),
				FirebirdODSMinorVersionDatabaseInformation()], logger: logger)
			
			let statement = connection.createStatement("SELECT PHONE_EXT FROM employee")
			
			var transactionParameters = FirebirdTransactionParameterBuffer()
			transactionParameters.add(parameter: FirebirdVersion3TransactionParameter())
			let transaction = try connection.startTransaction(parameters: transactionParameters)
			
			let results = try connection.execute(statement, transaction: transaction, logger: logger)
			
			let decoder = FirebirdDecoder()
			for row in results.rows {
				for column in row.columns {
					let value = try decoder.decode(String.self, from: column.data, context: column.context)
					print(row.index, column.name, value)
				}
			}
		} catch let error as FirebirdError {
			print(error.description)
			throw error
		}*/
	}
}
