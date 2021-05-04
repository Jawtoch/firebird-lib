//
//  FirebirdConnectionConfiguration.swift
//  
//
//  Created by Ugo Cottin on 06/03/2021.
//

public struct FirebirdConnectionConfiguration: CustomStringConvertible {
	
	/// The host of the database
	let host: FirebirdDatabaseHost
	
	/// Username used to login to the database server
	let username: String
	
	/// Password used to login to the databse server (NON ENCRYPTED)
	let password: String
	
	/// The database name to connect to
	let database: String
	
	/// Database url with host and port
	public var databaseURL: String {
		return "\(host):\(database)"
	}
	
	/// A description of the connection
	public var description: String {
		"\(self.username)@\(self.databaseURL)"
	}
	
	public init(hostname: String, port: UInt16? = nil, username: String, password: String, database: String) {
		self.init(host: .init(hostname: hostname, port: port), username: username, password: password, database: database)
	}
	
	public init(host: FirebirdDatabaseHost, username: String, password: String, database: String) {
		self.host = host
		self.username = username
		self.password = password
		self.database = database
	}
	
}
