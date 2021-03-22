//
//  FirebirdTests.swift
//  
//
//  Created by ugo cottin on 21/03/2021.
//

import XCTest
@testable import Firebird

final class FirebirdTests: XCTestCase {
	
	func testStatus() {
		let firebird = Firebird()
		XCTAssertNotNil(firebird.status)
	}
	
}
