//
//  FirebirdDatabase.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

public protocol FirebirdDatabase {
	
	/// The database logger
	var logger: Logger { get }
	
	func withConnection<T>(_ closure: @escaping (FirebirdConnection) throws -> T) rethrows -> T
	
	/// Perform a query that dont return data
	/// - Parameters:
	///   - query: a query string
	///   - binds: query parameters
	func simpleQuery(_ query: String, _ binds: [FirebirdData]) throws

	/// Perform a query that return datas
	/// - Parameters:
	///   - query: a query string
	///   - binds: query parameters
	/// - Returns: the result rows
	func query(_ query: String, _ binds: [DataConvertible]) throws -> [FirebirdRow]
	
	func withTransaction<T>(_ closure: @escaping(() throws -> T)) throws -> T
}

