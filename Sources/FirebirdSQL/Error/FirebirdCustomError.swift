
//
//  FirebirdCustomError.swift
//  
//
//  Created by ugo cottin on 15/03/2022.
//

struct FirebirdCustomError: FirebirdError {
		
	let reason: String
	
	var description: String {
		self.reason
	}
	
	init(reason: String) {
		self.reason = reason
	}
	
}
