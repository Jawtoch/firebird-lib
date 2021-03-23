//
//  File.swift
//  
//
//  Created by ugo cottin on 20/03/2021.
//

public struct Firebird {
	
	public static let dialect: UInt16 = 3
	
	public var name: String = "Hello, Firebird!"
	public var array: Array<ISC_STATUS> = Array(repeating: 0, count: Int(ISC_STATUS_LENGTH))
	
	public init() { }
	
	public var status: Int32 {
		var array = self.array
		let code = isc_sqlcode(&array)
		print("code: \(code)")
		return code
	}
}

/// Prepare and execute a quey string, with or without parameters, that does not return data
/// - Parameters:
///   - query: the query string to be executed
///   - connection: an opened connection to the database
///   - transaction: an opened transaction on the database
///   - dialect: the dialect version of the query
///   - descriptorArea: a descriptor area containing the parameters of this query
/// - Throws: If an error occur during the execution of the query
public func execute(_ query: String, on connection: FirebirdConnection, with transaction: FirebirdTransaction, dialect: UInt16 = Firebird.dialect, descriptorArea: FirebirdDescriptorArea? = nil) throws {
	var status = FirebirdError.statusArray
	
	let descriptorAreaPointer: UnsafePointer<XSQLDA>?
	if let descriptorArea = descriptorArea {
		// Mark: Not the best thing in the world…
		descriptorAreaPointer = withUnsafePointer(to: descriptorArea.handle) { $0 }
	} else {
		descriptorAreaPointer = nil
	}
	
	if isc_dsql_execute_immediate(&status, &connection.handle, &transaction.handle, 0, query, dialect, descriptorAreaPointer) > 0 {
		throw FirebirdError(from: status)
	}
}
