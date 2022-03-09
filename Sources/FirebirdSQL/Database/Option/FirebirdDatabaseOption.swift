//
//  FirebirdDatabaseOption.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

protocol FirebirdDatabaseOption: DatabaseOption {
	
	typealias Element = ISC_SCHAR
	
	var buffer: [Element] { get }
	
}
