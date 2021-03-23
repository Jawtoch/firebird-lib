//
//  FirebirdDatabase+Statement.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

public extension FirebirdDatabase {
	
	func prepare(_ statement: FirebirdStatement, with transaction: FirebirdTransaction, dialectVersion: UInt16 = Firebird.dialect) throws {
		var status = FirebirdError.statusArray
		
		if isc_dsql_prepare(&status, &transaction.handle, &statement.handle, 0, statement.query, dialectVersion, nil) > 0 {
			throw FirebirdError(from: status)
		}
		
		self.logger.info("Statement \(statement) prepared")
	}
}
