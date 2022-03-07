//
//  FirebirdTests.swift
//  
//
//  Created by ugo cottin on 21/03/2021.
//

import XCTest
@testable import Firebird

final class FirebirdTests: XCTestCase {

	private var hostname: String {
		guard let hostname = ProcessInfo.processInfo.environment["FB_TEST_HOSTNAME"] else {
			fatalError("FB_TEST_HOSTNAME is not defined")
		}
		
		return hostname
	}
	
	private var port: UInt16? {
		guard let port = ProcessInfo.processInfo.environment["FB_TEST_PORT"] else { return nil }
		
		return UInt16(port)
	}
	
	private var username: String {
		guard let username = ProcessInfo.processInfo.environment["FB_TEST_USERNAME"] else {
			fatalError("FB_TEST_USERNAME is not defined")
		}
		
		return username
	}
	
	private var password: String {
		guard let password = ProcessInfo.processInfo.environment["FB_TEST_PASSWORD"] else {
			fatalError("FB_TEST_PASSWORD is not defined")
		}
		
		return password
	}
	
	private var database: String {
		guard let database = ProcessInfo.processInfo.environment["FB_TEST_DATABASE"] else {
			fatalError("FB_TEST_DATABASE is not defined")
		}
		
		return database
	}
	
	private var configuration: FirebirdConnectionConfiguration {
		.init(
			hostname: self.hostname,
			port: self.port,
			username: self.username,
			password: self.password,
			database: self.database)
	}
	
	private var connection: FirebirdConnection!
	
	override func setUpWithError() throws {
		self.connection = try FirebirdConnection.connect(configuration)
	}
	
	override func tearDownWithError() throws {
		try self.connection?.close()
	}
	
	func testConnect() throws {
		let connection = try FirebirdConnection.connect(configuration)
		XCTAssertTrue(connection.isOpened)
		try connection.close()
	}
	
	func testClosingClosedConnection() throws {
		try self.connection.close()
		try self.connection.close()
	}
	
	func testConnectWithDefaultPort() throws {
		let configuration = FirebirdConnectionConfiguration(
			hostname: self.hostname,
			username: self.username,
			password: self.password,
			database: self.database)
		let connection = try FirebirdConnection.connect(configuration)
		XCTAssertTrue(connection.isOpened)
		try connection.close()
	}
	
	func testConnectWithWrongCredentials() throws {
		let configuration = FirebirdConnectionConfiguration(
			hostname: self.hostname,
			port: self.port,
			username: "Foo",
			password: "Bar",
			database: self.database)
		XCTAssertThrowsError(try FirebirdConnection.connect(configuration))
	}
	
	func testTransaction() throws {
		let transaction = try self.connection.startTransaction(on: self.connection)
		XCTAssertTrue(transaction.isOpened)
		try self.connection.commitTransaction(transaction)
	}
	
	func testRollbackTransaction() throws {
		let transaction = try self.connection.startTransaction(on: self.connection)
		XCTAssertTrue(transaction.isOpened)
		try self.connection.rollbackTransaction(transaction)
	}
    
    func testQuery() throws {
        try self.connection.query("SELECT emp_firstname FROM employee") { row in
            for (column, dataConvertible) in row.values {
                let firstName = String(dataConvertible.data!, using: dataConvertible.context) ?? "<empty>"
                print(row.index, column, firstName.replacingOccurrences(of: " ", with: "."))
            }
        }
    }
	
	static var allTests = [
		("testConnect", testConnect),
		("testClosingClosedConnection", testClosingClosedConnection),
		("testConnectWithDefaultPort", testConnectWithDefaultPort),
		("testConnectWithWrongCredentials", testConnectWithWrongCredentials),
		("testTransaction", testTransaction),
		("testRollbackTransaction", testRollbackTransaction),
	]
}
