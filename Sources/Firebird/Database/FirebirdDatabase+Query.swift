//
//  FirebirdDatabase.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

public extension FirebirdDatabase {
	
	func query(_ query: String, _ binds: [FirebirdData]) throws -> [FirebirdRow] {
		return try self.withConnection { connection in
			let transaction = try self.startTransaction(on: connection)
			
			let statement = FirebirdStatement(query, logger: self.logger)
			try statement.allocate(on: connection)
			
			try self.commitTransaction(transaction)
			try statement.free()
			return []
		}
	}
}
