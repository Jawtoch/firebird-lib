//
//  Database.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

protocol Database {
    
    associatedtype Statement: FirebirdSQL.Statement
    
    associatedtype Transaction: FirebirdSQL.Transaction
	
	var isAttached: Bool { get }
	
	func attach(_ database: String) throws
	
	func detach() throws
	
	func create(_ database: String) throws
	
	func drop() throws
	
    // MARK: Transaction
    func startTransaction() throws -> Transaction
}
