//
//  Database.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

protocol Database {
	
	var isAttached: Bool { get }
	
	func attach(_ database: String) throws
	
	func detach() throws
	
	func create(_ database: String) throws
	
	func drop() throws
	
}
