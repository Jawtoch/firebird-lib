//
//  FirebirdDataConvertible.swift
//  
//
//  Created by ugo cottin on 27/06/2022.
//

import Foundation

public protocol FirebirdDataConvertible {
	
	init(firebirdData: FirebirdData) throws
	
	func firebirdData(metadata: FirebirdData.Metadata) throws -> Data?
}
