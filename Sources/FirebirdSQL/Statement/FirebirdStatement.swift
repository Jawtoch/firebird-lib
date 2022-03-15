//
//  FirebirdStatement.swift
//  
//
//  Created by Ugo Cottin on 14/03/2022.
//

import fbclient


protocol FirebirdStatement: AnyObject {
		
	var handle: isc_stmt_handle { get set }
    
	var status: [ISC_STATUS] { get }
	
	var query: String { get }
	
	var dialect: UInt16 { get }
	
	func allocate(on database: FirebirdDatabase) throws
	
	func prepare(with transaction: FirebirdTransaction) throws

	func executeImmediate(on database: FirebirdDatabase, transaction: FirebirdTransaction) throws
	
	func execute(with transaction: FirebirdTransaction) throws
}
