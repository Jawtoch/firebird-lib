//
//  FirebirdConnection+Database.swift
//  
//
//  Created by Ugo Cottin on 24/03/2021.
//

extension FirebirdConnection: FirebirdDatabase {
	public func withConnection<T>(_ closure: @escaping (FirebirdConnection) throws -> T) rethrows -> T {
		try closure(self)
	}
	
	public func withTransaction<T>(_ closure: @escaping(() throws -> T)) throws -> T {
		try self.withConnection { conn in
			let transaction = try self.startTransaction(on: conn)
			do {
				let result = try closure()
				try self.commitTransaction(transaction)
				return result
			} catch let error {
				try self.rollbackTransaction(transaction)
				throw error
			}
		}
	}
}
