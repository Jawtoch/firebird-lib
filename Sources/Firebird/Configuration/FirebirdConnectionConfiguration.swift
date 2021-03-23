//
//  FirebirdConnectionConfiguration.swift
//  
//
//  Created by Ugo Cottin on 06/03/2021.
//

import Foundation

public struct FirebirdConnectionConfiguration: CustomStringConvertible {
	
	let host: FirebirdDatabaseHost
	
	let username: String
	let password: String
	
	let database: String
	
	public var databaseURL: String {
		return "\(host):\(database)"
	}
	
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
