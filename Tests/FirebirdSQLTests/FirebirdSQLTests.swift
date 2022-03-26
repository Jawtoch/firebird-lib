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

	func testConnection() async throws {
		do {
			var logger = Logger(label: "test.firebirdsql")
			logger.logLevel = .debug
			var connectionParameters = ConnectionParameterBuffer()
			
			connectionParameters.add(parameter: Version1ConnectionParameter())
			connectionParameters.add(parameter: DialectConnectionParameter(.v6))
			connectionParameters.add(parameter: UsernameConnectionParameter("SYSDBA"))
			connectionParameters.add(parameter: PasswordConnectionParameter("SMETHING"))
			
			let connection = try await Connection.connect(to: "127.0.0.1", database: "employee", parameters: connectionParameters, logger: logger)
			XCTAssertFalse(connection.isClosed)
			
			try connection.requestInformations([ODSVersionDatabaseInformation(), ODSMinorVersionDatabaseInformation()], logger: logger)
			
			let statement = connection.createStatement("SELECT PHONE_EXT FROM employee")
			
			var transactionParameters = TransactionParameterBuffer()
			transactionParameters.add(parameter: Version3TransactionParameter())
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
		}
	}
}
