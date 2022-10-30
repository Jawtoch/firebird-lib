import CFirebird
import Foundation
import Logging

public protocol FirebirdConnection {
	
	var logger: Logger { get }
	
	var handle: isc_db_handle { get set }
	
	var isClosed: Bool { get }
	
	func attach(_ url: String, parameters: [ISC_SCHAR]) throws
	
	func detach() throws
	
}

public extension FirebirdConnection {
	
	func attach(hostname: String, port: UInt16, database: String, username: String, password: String, parameters: [FirebirdConnectionParameter] = [.version1]) throws {
		let allParameters = parameters + [.username(username), .password(password)]
		try self.attach(hostname: hostname, port: port, database: database, parameters: allParameters)
	}
	
	func attach(hostname: String, port: UInt16, database: String, parameters: [FirebirdConnectionParameter] = []) throws {
		let parametersBuffer = parameters.flatMap { $0.rawValue }
        try self.attach(hostname: hostname, port: port, database: database, parameters: parametersBuffer)
	}
	
	func attach(hostname: String, port: UInt16, database: String, parameters: [ISC_SCHAR] = []) throws {
		let databaseUrl = "\(hostname)/\(port):\(database)"
		try self.attach(databaseUrl, parameters: parameters)
	}
	
}
