//
//  FirebirdTransactionExistenceBlock.swift
//  
//
//  Created by ugo cottin on 08/03/2022.
//

import fbclient

public struct FirebirdTransactionExistenceBlock {
	
	public let database: UnsafePointer<isc_db_handle>
	
	public let count: CLong
	
	public let parameters: UnsafeBufferPointer<CChar>
	
}
