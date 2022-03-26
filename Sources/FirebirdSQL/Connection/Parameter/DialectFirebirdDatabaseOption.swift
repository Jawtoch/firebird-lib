//
//  DialectConnectionParameter.swift
//
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

public struct DialectConnectionParameter: ConnectionParameter {
	
	public enum Dialect: Int {
		case compatible = 1
		case diagnostic = 2
		case v6 = 3
	}
	
	public let value: Dialect
	
	public var description: String {
		"Dialect \(self.value)"
	}
	
	public var rawBytes: [ISC_SCHAR] {
		[ISC_SCHAR(isc_dpb_sql_dialect), 1, ISC_SCHAR(self.value.rawValue)]
	}
	
	public init(_ dialect: Dialect) {
		self.value = dialect
	}
}
