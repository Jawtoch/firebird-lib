//
//  FirebirdTests.swift
//  
//
//  Created by ugo cottin on 21/03/2021.
//

import XCTest
@testable import Firebird

final class FirebirdTests: XCTestCase {

	private let hostname: String! 	= "localhost"
	
	private let port: UInt16! 		= 3051
	
	private let username: String! 	= "SYSDBA"
	
	private let password: String! 	= "MASTERKEY"
	
	private let database: String!	= "EMPLOYEE"
	
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
	
	static var allTests = [
		("testConnect", testConnect),
		("testTransaction", testTransaction),
		("testRollbackTransaction", testRollbackTransaction),
	]
}
