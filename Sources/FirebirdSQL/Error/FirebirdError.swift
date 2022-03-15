//
//  FirebirdError.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

import fbclient

protocol FirebirdError: Error, CustomStringConvertible {
	
	var reason: String { get }
		
}

extension FirebirdError {
	var description: String {
		self.reason
	}
}
