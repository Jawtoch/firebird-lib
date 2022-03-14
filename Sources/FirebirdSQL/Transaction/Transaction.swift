//
//  Transaction.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

protocol Transaction {
    
    associatedtype Database: FirebirdSQL.Database
	
	func prepare() throws
	
	func start(on database: Database) throws
	
	func commit() throws
	
	func rollback() throws
	
}
