//
//  Version1ConnectionParameter.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

public struct Version1ConnectionParameter: ConnectionParameter {
	public var description: String {
		"Version1"
	}
	
	public var rawBytes: [ISC_SCHAR] {
		[ISC_SCHAR(isc_dpb_version1)]
	}
}
