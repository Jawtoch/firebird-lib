import Logging
import XCTest
@testable import Firebird

class FirebirdTests: XCTestCase {

    func testCoding() throws {
        let encoder = FBEncoder()
        let decoder = FBDecoder()
        
        let value = "hello world"
        let data = FirebirdData(name: "dummy", type: .text, subType: .null, length: 0, scale: 0, value: nil)
        
        let encoded = try encoder.encode(value, into: data)
        let decoded = try decoder.decode(String.self, from: encoded)
        
        XCTAssertEqual(value, decoded)
    }
    
}
