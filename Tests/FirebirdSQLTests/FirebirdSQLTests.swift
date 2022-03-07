//
//  FirebirdSQLTests.swift
//  
//
//  Created by ugo cottin on 03/03/2022.
//

import XCTest
@testable import FirebirdSQL
import fbclient

class FirebirdSQLTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        var database = Database()
        var parameters = DatabaseParameters()
        parameters.append(contentOf: [
            .version1,
            .username("SYSDBA"),
            .password("SMETHING")
        ])
        
        try database.attach("localhost/3050:/firebird/db0.gdb", parameters: parameters)
        
        var infos = DatabaseInfos()
        infos.append(contentOf: [
			.allocation,
			.odsVersion,
			.odsMinorVersion
        ])
        
//        let res = try database.getInformations(infos)
//        var p = res
//        withUnsafeMutablePointer(to: &p[0]) { pptr in
//            var localPtr = pptr
//            var item: ISC_SCHAR = 0
//
//            while item != isc_info_end {
//                item = localPtr.pointee
//                localPtr = localPtr.advanced(by: 1)
//                let length = isc_vax_integer(localPtr, 2)
//                localPtr = localPtr.advanced(by: 2)
//
//                switch item {
//                case ISC_SCHAR(isc_info_ods_version.rawValue):
//                    let version = isc_vax_integer(localPtr, Int16(length))
//                    print("major", version)
//                    break
//                case ISC_SCHAR(isc_info_ods_minor_version.rawValue):
//                    let version = isc_vax_integer(localPtr, Int16(length))
//                    print("minor", version)
//                    break
//                default:
//                    break
//                }
//
//                localPtr = localPtr.advanced(by: Int(length))
//            }
//        }
//        print(res)
        
        let informations = try database.getInformations(infos)
		print(informations)
    }
    
    func testDatabaseParameter() throws {
        var parameters = DatabaseParameters()
        parameters.append(.version1)
        parameters.append(contentOf: [
            .username("SYSDBA"),
            .password("SMETHING")
        ])
        
        print(parameters.buffer.map { String(format: "%02x", $0) })
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
