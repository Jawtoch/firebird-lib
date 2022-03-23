//
//  FirebirdSQLTests.swift
//  
//
//  Created by ugo cottin on 03/03/2022.
//

import XCTest
@testable import FirebirdSQL
import fbclient
import Logging

class FirebirdSQLTests: XCTestCase {

	var database: FirebirdDatabase!
	
    override func setUpWithError() throws {
		let database = FirebirdDatabase()
		database.addOptions([
			Version1FirebirdDatabaseOption(),
			DialectFirebirdDatabaseOption(.v6),
			UsernameFirebirdDatabaseOption("SYSDBA"),
			PasswordFirebirdDatabaseOption("SMETHING")
		])
		self.database = database
    }

    override func tearDownWithError() throws {
		if self.database.isAttached {
			try self.database.detach()
		}
    }
	
	func testCreateDatabase() throws {
		let dbUrl = "localhost/3050:/firebird/foobar.gdb"
		try self.database.create(dbUrl)
		XCTAssertTrue(self.database.isAttached)
	}
	
	func testDropDatabase() throws {
		let dbUrl = "localhost/3050:/firebird/foobar.gdb"
		try self.database.attach(dbUrl)
		XCTAssertTrue(self.database.isAttached)
		try self.database.drop()
		XCTAssertFalse(self.database.isAttached)
		XCTAssertThrowsError(try self.database.attach(dbUrl))
	}
	
	func testAttachDatabase() throws {
		try self.database.attach("localhost/3050:employee")
		XCTAssertTrue(self.database.isAttached)
	}

    func testExample() throws {
        try database.attach("localhost/3050:/firebird/db0.gdb")
        
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
		let database = FirebirdDatabase()
		try database.attach("localhost/3050:employee")
		
		let transaction = FirebirdTransaction()
		transaction.addOption(Version3FirebirdTransactionOption())
		/*transaction.addOptions([
			Int8(isc_tpb_version3),
			Int8(isc_tpb_write),
			Int8(isc_tpb_concurrency),
			Int8(isc_tpb_wait)
		])*/
		
		try transaction.start(on: database)
		XCTAssertGreaterThan(transaction.handle, 0)
	}
	
	func testConnection() async throws {
		var logger = Logger(label: "test.firebirdsql")
		logger.logLevel = .debug
		var parameters = ConnectionParameterBuffer()
		
		parameters.add(parameter: Version1FirebirdDatabaseOption())
		parameters.add(parameter: DialectFirebirdDatabaseOption(.v6))
		parameters.add(parameter: UsernameFirebirdDatabaseOption("SYSDBA"))
		parameters.add(parameter: PasswordFirebirdDatabaseOption("SMETHING"))
		
		do {
			let connection = try await Connection.connect(to: "saturn.local", database: "employee", parameters: parameters, logger: logger)
			XCTAssertFalse(connection.isClosed)
		} catch let error as FirebirdError {
			print(error.description)
			throw error
		}
		
	}
}
