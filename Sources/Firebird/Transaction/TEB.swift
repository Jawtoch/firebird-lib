//
//  TEB.swift
//  
//
//  Created by ugo cottin on 24/06/2022.
//

import CFirebird

internal struct TEB {
	
	internal let database: UnsafePointer<isc_db_handle>
	
	internal let count: CLong
	
	internal let parameters: UnsafeBufferPointer<CChar>?
	
}
