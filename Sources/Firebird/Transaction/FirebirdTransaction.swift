//
//  FirebirdTransaction.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

public class FirebirdTransaction {
	
	public var handle: isc_tr_handle
	
	/// If the transaction is opened
	public var isOpened: Bool {
		self.handle > 0
	}
	
	public init(handle: isc_tr_handle = 0) {
		self.handle = handle
	}
	
}
