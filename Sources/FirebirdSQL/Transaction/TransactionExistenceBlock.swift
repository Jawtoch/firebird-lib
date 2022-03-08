//
//  File.swift
//  
//
//  Created by ugo cottin on 08/03/2022.
//

import fbclient

struct TransactionExistenceBlock {
	let database: UnsafePointer<isc_db_handle>
	let count: CLong
	let parameters: UnsafeBufferPointer<CChar>
}
