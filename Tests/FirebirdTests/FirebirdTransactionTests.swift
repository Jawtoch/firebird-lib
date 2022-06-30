//
//  FirebirdTransactionTests.swift
//  
//
//  Created by ugo cottin on 30/06/2022.
//

import Logging
import NIOCore
import XCTest

@testable import Firebird

class FirebirdTransactionTests: XCTestCaseInEventLoop {

	var logger: Logger!
	
	override func setUp() {
		super.setUp()
		self.logger = Logger(label: "test.transaction.firebird")
	}
	
	func testCommitTransaction() throws {
		let connection = FBConnection(
			configuration: FirebirdTests.configuration,
			logger: self.logger,
			on: self.eventLoop)
		
		let futureConnectedConnection = connection.connect().map { connection }
				
		let futureTransaction = futureConnectedConnection.flatMap { $0.startTransaction() }
		futureTransaction.whenSuccess { transaction in
			XCTAssertFalse(transaction.isClosed)
		}
		
		let futureCommitedTransaction = futureTransaction.flatMap { transaction in
			transaction.commit().map { transaction } }
		
		futureCommitedTransaction.whenSuccess { transaction in
			XCTAssertTrue(transaction.isClosed)
		}
		
		let futureClosedConnection = futureConnectedConnection.and(futureCommitedTransaction).flatMap { (connection, transaction) in
			connection.close()
		}
		
		try futureClosedConnection.wait()
	}
	
	func testRollbackTransaction() throws {
		let connection = FBConnection(
			configuration: FirebirdTests.configuration,
			logger: self.logger,
			on: self.eventLoop)
		
		let futureConnectedConnection = connection.connect().map { connection }
		
		let futureTransaction = futureConnectedConnection.flatMap { $0.startTransaction() }
		futureTransaction.whenSuccess { transaction in
			XCTAssertFalse(transaction.isClosed)
		}
		
		let futureCommitedTransaction = futureTransaction.flatMap { transaction in
			transaction.rollback().map { transaction } }
		
		futureCommitedTransaction.whenSuccess { transaction in
			XCTAssertTrue(transaction.isClosed)
		}
		
		let futureClosedConnection = futureConnectedConnection.and(futureCommitedTransaction).flatMap { (connection, transaction) in
			connection.close()
		}
		
		try futureClosedConnection.wait()
	}

}
