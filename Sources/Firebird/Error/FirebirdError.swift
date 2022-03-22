//
//  FirebirdError.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

import fbclient

public protocol FirebirdError: Error, CustomStringConvertible {
	
	var reason: String { get }
		
}

extension FirebirdError {
	public var description: String {
		self.reason
	}
}
