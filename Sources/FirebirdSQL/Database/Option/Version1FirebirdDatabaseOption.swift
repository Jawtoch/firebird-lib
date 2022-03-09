//
//  Version1FirebirdDatabaseOption.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

struct Version1FirebirdDatabaseOption: FirebirdDatabaseOption {
	var description: String {
		"Version1"
	}
	
	var buffer: [Int8] {
		[Int8(isc_dpb_version1)]
	}
}
