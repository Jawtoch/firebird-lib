//
//  Database.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import Logging

public protocol Database {
	
	var logger: Logger { get }
	
	func execute(_ statement: Statement, logger: Logger) async -> Void
	
	func withConnection<T>(_ closure: @escaping () async -> T) async -> T
}

extension Database {
	
	public func logging(to logger: Logger) -> Database {
		DatabaseWithCustomLogger(database: self, logger: logger)
	}
	
}
