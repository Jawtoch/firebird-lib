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
}
