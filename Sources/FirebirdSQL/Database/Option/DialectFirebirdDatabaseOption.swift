//
//  DialectFirebirdDatabaseOption.swift
//
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

struct DialectFirebirdDatabaseOption: FirebirdDatabaseOption {
	
	enum Dialect: Int {
		case compatible = 1
		case diagnostic = 2
		case v6 = 3
	}
	
	let value: Dialect
	
	var description: String {
		"Dialect \(self.value)"
	}
	
	var buffer: [Element] {
		[Element(isc_dpb_sql_dialect), 1, Element(self.value.rawValue)]
	}
	
	init(_ dialect: Dialect) {
		self.value = dialect
	}
}
