import XCTest
@testable import firebird_lib

final class firebird_libTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(firebird_lib().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
