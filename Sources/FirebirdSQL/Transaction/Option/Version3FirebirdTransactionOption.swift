//
//  Version3FirebirdTransactionOption.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

struct Version3FirebirdTransactionOption: FirebirdTransactionOption {
	
	var description: String {
		"Version3"
	}
	
	var buffer: [Element] {
		[Element(isc_tpb_version3)]
	}
	
}

extension Version3FirebirdTransactionOption: TransactionParameter {
	
	var rawBytes: [ISC_SCHAR] {
		self.buffer
	}
	
}
