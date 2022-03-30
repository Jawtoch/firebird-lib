//
//  FirebirdTransaction.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

public class FirebirdTransaction {
	
	public var handle: isc_tr_handle
	
	public var isActive: Bool {
		self.handle > 0
	}
	
	public init(handle: isc_tr_handle) {
		self.handle = handle
	}
	
	public func commit() throws {
		try withStatus { status in
			isc_commit_transaction(&status, &self.handle)
		}
	}
	
	public func rollback() throws {
		try withStatus { status in
			isc_rollback_transaction(&status, &self.handle)
		}
	}
}
