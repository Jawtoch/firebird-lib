//
//  Database.swift
//  
//
//  Created by ugo cottin on 03/03/2022.
//

import fbclient

class FirebirdDatabase: Database {
	
	var handle: isc_db_handle
	
	var status: [ISC_STATUS]
	
	var isAttached: Bool {
		self.handle > 0
	}
	
	var options: [FirebirdDatabaseOption]
	
	init() {
		self.handle = 0
		self.status = FirebirdError.statusArray
		self.options = []
	}
	
	func addOption(_ option: FirebirdDatabaseOption) {
		self.options.append(option)
	}
	
	func addOptions(_ options: [FirebirdDatabaseOption]) {
		options.forEach { self.options.append($0) }
	}
	
	func attach(_ database: String) throws {
		var cDatabaseName = database.cString(using: .utf8)!
		
		var buffer = self.options.flatMap { $0.buffer }
		let bufferCount = Int16(buffer.count)
		try withUnsafePointer(to: &buffer[0]) { bufferPointer in
			if isc_attach_database(&self.status, Int16(cDatabaseName.count), &cDatabaseName, &self.handle, bufferCount, bufferPointer) > 0 {
				throw FirebirdError(from: self.status)
			}
		}
	}
	
	func detach() throws {
		if isc_detach_database(&self.status, &self.handle) > 0 {
			throw FirebirdError(from: self.status)
		}
	}
	
	func create(_ database: String) throws {
		var cDatabaseName = database.cString(using: .utf8)!
		
		var buffer = self.options.flatMap { $0.buffer }
		let bufferCount = Int16(buffer.count)
		
		try withUnsafePointer(to: &buffer[0]) { bufferPointer in
			if isc_create_database(&self.status, Int16(cDatabaseName.count), &cDatabaseName, &self.handle, bufferCount, bufferPointer, .zero) > 0 {
				throw FirebirdError(from: self.status)
			}
		}
	}
	
	func drop() throws {
		if isc_drop_database(&self.status, &self.handle) > 0 {
			throw FirebirdError(from: self.status)
		}
	}
	
	func getInformations(_ informations: DatabaseInfos) throws -> [DatabaseInfo: ISC_LONG] {
		var buffer = informations.buffer
		let bufferCount = Int16(buffer.count)
		
		let resultSize = 40
		var informations: [ISC_SCHAR] = Array(repeating: .zero, count: resultSize)
		
		let res = withUnsafePointer(to: &buffer[0]) { bufferPointer in
			withUnsafeMutablePointer(to: &informations[0]) { informationsPointer in
				isc_database_info(&self.status, &self.handle, bufferCount, bufferPointer, Int16(resultSize), informationsPointer)
			}
		}
		
		if (res > .zero) {
			throw FirebirdError(from: self.status)
		}
		
		var parsedInformations: [DatabaseInfo: ISC_LONG] = [:]
		informations.withUnsafeBufferPointer { buffer in
			
			guard let baseAddress = buffer.baseAddress else { return }
			
			var index = 0
			while index < buffer.endIndex {
				let information = baseAddress.advanced(by: index).pointee
				index += 1
				
				if information == isc_info_end {
					break
				}
				
				let length = isc_vax_integer(baseAddress.advanced(by: index), 2)
				index += 2
				let value = isc_vax_integer(baseAddress.advanced(by: index), Int16(length))
				index += Int(length)
				
				if let databaseInformation = DatabaseInfo(rawValue: DatabaseInfo.RawValue(information)) {
					parsedInformations[databaseInformation] = value
				}
			}
		}
		
		return parsedInformations
	}
}
