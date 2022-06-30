//
//  FirebirdAllocationPool.swift
//
//
//  Created by ugo cottin on 25/06/2022.
//

import CFirebird

protocol FirebirdAllocationPool {
	
	func allocate(bind: FirebirdBind)
	
	func release()
	
}
