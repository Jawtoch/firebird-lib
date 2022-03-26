//
//  Transaction.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

public class Transaction {
	
	public var handle: isc_tr_handle
	
	public var isActive: Bool {
		self.handle > 0
	}
	
	public init(handle: isc_tr_handle) {
		self.handle = handle
	}
	
}
