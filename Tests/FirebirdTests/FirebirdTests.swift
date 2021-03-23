//
//  FirebirdTests.swift
//  
//
//  Created by ugo cottin on 21/03/2021.
//

import XCTest
@testable import Firebird

final class FirebirdTests: XCTestCase {
	
	func testConnect() throws {
		let configuration = FirebirdConnectionConfiguration(
			hostname: "localhost",
			port: 3051,
			username: "SYSDBA",
			password: "MASTERKEY",
			database: "EMPLOYEE")
		
		let connection = try FirebirdConnection.connect(configuration)
		try connection.close()
	}
	
	func testQuery() {
		
	}
}
