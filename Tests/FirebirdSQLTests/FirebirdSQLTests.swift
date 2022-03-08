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

	let parameters: [DatabaseParameter] = [
		.version1,
		.username("SYSDBA"),
		.password("SMETHING")
	]
	
	var database: Database!
	
    override func setUpWithError() throws {
		self.database = Database()
    }

    override func tearDownWithError() throws {
		if self.database.isAttached {
			try self.database.detach()
		}
    }
	
	func testCreateDatabase() throws {
		let dbUrl = "localhost/3050:/firebird/foobar.gdb"
		var parameters = DatabaseParameters()
		parameters.append(contentOf: [
			.version1,
			.dialect(.compatible),
			.username("SYSDBA"),
			.password("SMETHING")
		])
		try self.database.create(dbUrl, parameters: parameters)
	}
	
	func testDropDatabase() throws {
		let dbUrl = "localhost/3050:/firebird/foobar.gdb"
		try self.database.attach(dbUrl, parameters: self.parameters)
		XCTAssertTrue(self.database.isAttached)
		try self.database.drop()
		XCTAssertFalse(self.database.isAttached)
		XCTAssertThrowsError(try self.database.attach(dbUrl, parameters: self.parameters))
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
	
	func testStartTransaction() throws {
		var database = Database()
		try database.attach("localhost/3050:employee", parameters: self.parameters)
		
		var transaction = Transaction()
		transaction.addOptions([
			Int8(isc_tpb_version3),
			Int8(isc_tpb_write),
			Int8(isc_tpb_concurrency),
			Int8(isc_tpb_wait)
		])
		
		try transaction.start(on: database)
		XCTAssertGreaterThan(transaction.handle, 0)
	}
}
