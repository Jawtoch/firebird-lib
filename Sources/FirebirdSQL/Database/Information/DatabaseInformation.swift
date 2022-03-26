//
//  DatabaseInformation.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

import fbclient

public protocol DatabaseInformation: CustomStringConvertible {
	
	typealias RawValue = db_info_types.RawValue
	
	var rawValue: RawValue { get }
}
