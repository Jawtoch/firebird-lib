//
//  FirebirdNonQueryStatement.swift
//  
//
//  Created by ugo cottin on 15/03/2022.
//

import fbclient

class FirebirdNonQueryStatement: FirebirdStatement {
	
	private enum State {
		case unallocated
		case allocated
		case prepared
	}
	
	var handle: isc_stmt_handle
	
	var status: [ISC_STATUS]
	
	let query: String
	
	let dialect: UInt16
	
	let encoding: String.Encoding
	
	let parameters: [Any]
	
	private var state: State
	
	private var database: FirebirdDatabase?
	
	init(_ query: String, _ parameters: [Any], dialect: Int32, _ encoding: String.Encoding = .utf8) throws {
		self.handle = .zero
		self.status = FirebirdVectorError.vector
		self.state = .unallocated
		self.database = nil
		
		self.query = query
		self.parameters = parameters
		guard let dialect = UInt16(exactly: dialect) else {
			throw FirebirdCustomError(reason: "Wrong dialect version number")
		}
		
		self.dialect = dialect
		self.encoding = encoding
	}
	
	func allocate(on database: FirebirdDatabase) throws {
		if isc_dsql_allocate_statement(&self.status, &database.handle, &self.handle) > 0 {
			throw FirebirdVectorError(from: self.status)
		}
		self.database = database
		self.state = .allocated
	}
	
	func prepare(with transaction: FirebirdTransaction) throws {
		guard self.state == .allocated else {
			throw FirebirdCustomError(reason: "Only allocated statement can be prepared")
		}
		
		let queryCString = self.query.cString(using: .utf8)!
		if isc_dsql_prepare(&self.status, &transaction.handle, &self.handle, 0, queryCString, self.dialect, .none) > 0 {
			throw FirebirdVectorError(from: self.status)
		}
		
		self.state = .prepared
	}
	
	func executeImmediate(on database: FirebirdDatabase, transaction: FirebirdTransaction) throws {
		guard let queryCString = self.query.cString(using: self.encoding) else {
			throw FirebirdCustomError(reason: "Unable to convert query to C string with \(self.encoding) encoding")
		}
		
		if isc_dsql_execute_immediate(&self.status, &database.handle, &transaction.handle, .zero, queryCString, self.dialect, .none) > 0 {
			throw FirebirdVectorError(from: self.status)
		}
	}
	
	func execute(with transaction: FirebirdTransaction) throws {
		guard self.state == .prepared else {
			throw FirebirdCustomError(reason: "Only prepared statement can be executed")
		}
		
		guard let database = self.database else {
			throw FirebirdCustomError(reason: "The prepared statement do not have a database")
		}
		
		guard database.isAttached else {
			throw FirebirdCustomError(reason: "The statement's database is not attached")
		}
		
		if isc_dsql_execute(&self.status, &transaction.handle, &database.handle, self.dialect, .none) > 0 {
			throw FirebirdVectorError(from: self.status)
		}

	}
}
