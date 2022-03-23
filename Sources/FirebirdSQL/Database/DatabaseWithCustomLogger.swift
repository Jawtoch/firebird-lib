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
	func execute(_ statement: Statement, logger: Logger) async {
		await self.database.execute(statement, logger: logger)
	}
	
	func withConnection<T>(_ closure: @escaping () async -> T) async -> T {
		await self.database.withConnection(closure)
	}
	
	
}
