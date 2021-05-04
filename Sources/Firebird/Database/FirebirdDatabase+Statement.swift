//
//  FirebirdDatabase+Statement.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

public extension FirebirdDatabase {
	
	func prepare(_ statement: FirebirdStatement, with transaction: FirebirdTransaction) throws {
		var status = FirebirdError.statusArray
		
		if isc_dsql_prepare(&status, &transaction.handle, &statement.handle, 0, statement.query, statement.dialect, nil) > 0 {
			throw FirebirdError(from: status)
		}
		
		self.logger.trace("Statement \(statement) prepared")
	}
}
