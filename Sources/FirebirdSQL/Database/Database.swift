//
//  Database.swift
//  
//
//  Created by ugo cottin on 03/03/2022.
//

import fbclient

struct Database {
    
    typealias Handle = isc_db_handle
    
    var handle: Handle
    
    init(_ handle: Handle = .zero) {
        self.handle = handle
    }
    
    
    mutating func attach(_ database: String, parameters: DatabaseParameters?) throws {
        var errorArray = FirebirdError.statusArray
        var databaseName = database.cString(using: .utf8)!
        
        var result: ISC_STATUS
        if let parameters = parameters {
            var buffer = parameters.buffer
            let bufferLength = Int16(buffer.count)
            result = withUnsafePointer(to: &buffer[0]) { bufferPointer in
                isc_attach_database(&errorArray, Int16(databaseName.count), &databaseName, &self.handle, bufferLength, bufferPointer)
            }
        } else {
            result = isc_attach_database(&errorArray, Int16(databaseName.count), &databaseName, &self.handle, .zero, nil)
        }
        
        if (result > .zero) {
            throw FirebirdError(from: errorArray)
        }
    }
    
    mutating func detach() throws {
        var status = FirebirdError.statusArray
        if isc_detach_database(&status, &self.handle) > .zero {
            throw FirebirdError(from: status)
        }
    }
    
    mutating func drop() throws {
        var status = FirebirdError.statusArray
        if isc_drop_database(&status, &self.handle) > .zero {
            throw FirebirdError(from: status)
        }
    }
    
    mutating func getInformations(_ informations: DatabaseInfos) throws -> [DatabaseInfo: ISC_LONG] {
        var status = FirebirdError.statusArray
        var buffer = informations.buffer
        let bufferSize = Int16(buffer.count)
        
        let resultSize = 40
        var informations: [ISC_SCHAR] = Array(repeating: .zero, count: resultSize)
        
        let res = withUnsafePointer(to: &buffer[0]) { bufferPointer in
            withUnsafeMutablePointer(to: &informations[0]) { informationsPointer in
                isc_database_info(&status, &self.handle, bufferSize, bufferPointer, Int16(resultSize), informationsPointer)
            }
        }

        if (res > .zero) {
            throw FirebirdError(from: status)
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
				
				/* guard information != 0 else {
					index += 3
					continue
				} */
				
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
