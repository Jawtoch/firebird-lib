//
//  FirebirdConnectionTests.swift
//  
//
//  Created by ugo cottin on 30/06/2022.
//

import Logging
import NIOCore
import XCTest

@testable import Firebird

class FirebirdConnectionTests: XCTestCaseInEventLoop {

	var logger: Logger!
	
	override func setUp() {
		super.setUp()
		self.logger = Logger(label: "test.connection.firebird")
	}
	
	func testConnect() throws {
		let connection = FBConnection(
			configuration: FirebirdTests.configuration,
			logger: self.logger,
			on: self.eventLoop)
		XCTAssertTrue(connection.isClosed)
		
		let futureConnectedConnection = connection.connect().map { connection }
		futureConnectedConnection.whenSuccess { connection in
			XCTAssertFalse(connection.isClosed)
		}
		
		let futureClosedConnection = futureConnectedConnection.flatMap { connection in
			connection.close()
		}
		
		try futureClosedConnection.wait()
	}

}
