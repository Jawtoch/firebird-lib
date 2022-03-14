//
//  FirebirdTransactionOption.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

protocol FirebirdTransactionOption: TransactionOption {
	
	typealias Element = ISC_SCHAR
	
	var buffer: [Element] { get }
	
}
