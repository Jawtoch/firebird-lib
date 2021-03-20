import XCTest

import firebird_libTests

var tests = [XCTestCaseEntry]()
tests += firebird_libTests.allTests()
XCTMain(tests)
