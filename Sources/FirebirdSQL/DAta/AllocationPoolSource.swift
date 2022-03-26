//
//  File.swift
//  
//
//  Created by Ugo Cottin on 24/03/2022.
//

import Logging

public protocol AllocationPoolSource {
	
	var isReleased: Bool { get }
	
	func makeAllocation(for variable: FirebirdSQLVariable, logger: Logger)
	
	func release(logger: Logger)
	
}
