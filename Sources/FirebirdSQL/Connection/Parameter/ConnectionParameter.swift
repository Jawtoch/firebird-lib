//
//  ConnectionParameter.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

import fbclient

public protocol ConnectionParameter: CustomStringConvertible {
	
	var rawBytes: [ISC_SCHAR] { get }
	
}
