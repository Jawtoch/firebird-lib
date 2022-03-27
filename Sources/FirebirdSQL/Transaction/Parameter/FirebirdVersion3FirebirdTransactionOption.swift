//
//  FirebirdVersion3TransactionParameter.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

public struct FirebirdVersion3TransactionParameter: FirebirdTransactionParameter {
	
	public var description: String {
		"Version3"
	}
	
	public var rawBytes: [ISC_SCHAR] {
		[ISC_SCHAR(isc_tpb_version3)]
	}
	
}
