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
    
    func testDateCoding() throws {
        let encoder = FBEncoder()
        let decoder = FBDecoder()
        
        let value = Date()
        let data = FirebirdData(name: "dummy", type: .timestamp, subType: .null, length: 0, scale: 0, value: nil)
        
        let encoded = try encoder.encode(value, into: data)
        let decoded = try decoder.decode(Date.self, from: encoded)
        
        XCTAssertEqual(value.timeIntervalSince1970.rounded(), decoded.timeIntervalSince1970)
    }
    
    func testQuery() throws {
        let logger = Logger(label: "test")
        let connection = FBConnection(logger: logger)
        try connection.attach(hostname: "localhost", port: 3051, database: "/databases/SIRXP-20221103.gdb", username: "SIRXP", password: "SMETHING")
        XCTAssertFalse(connection.isClosed)
        
        let column = "INVPRODGENERIQUE_GPB_CODPRINCIPAL"
        let rows = try connection.query("SELECT INVPRODGENERIQUE.GPB_CODPRINCIPAL AS \(column) FROM INVPRODGENERIQUE")
        for row in rows {
            let mrin = try row.decode(column: column, as: String.self)
            XCTAssertGreaterThan(mrin.count, 0)
        }
        
        try connection.detach()
        XCTAssertTrue(connection.isClosed)
    }
    
}
