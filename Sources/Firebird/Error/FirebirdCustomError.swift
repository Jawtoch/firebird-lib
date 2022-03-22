
//
//  FirebirdCustomError.swift
//  
//
//  Created by ugo cottin on 15/03/2022.
//

public struct FirebirdCustomError: FirebirdError {
	
	public let reason: String
	
	public init(reason: String) {
		self.reason = reason
	}
	
}
