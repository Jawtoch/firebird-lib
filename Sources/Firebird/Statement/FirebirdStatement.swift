//
//  FirebirdStatement.swift
//  
//
//  Created by ugo cottin on 25/06/2022.
//

import CFirebird

public protocol FirebirdStatement {
	
	func prepare()
	
	func run()
	
	func close()
	
}
