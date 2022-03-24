//
//  Transaction.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

public class Transaction {
	
	var handle: isc_tr_handle
	
	var isActive: Bool {
		self.handle > 0
	}
	
	init(handle: isc_tr_handle) {
		self.handle = handle
	}
	
}
