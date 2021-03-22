//
//  File.swift
//  
//
//  Created by ugo cottin on 20/03/2021.
//

struct Firebird {
	var name: String = "Hello, Firebird!"
	var array: Array<ISC_STATUS> = Array(repeating: 0, count: Int(ISC_STATUS_LENGTH))
	
	var status: Int32 {
		var array = self.array
		let code = isc_sqlcode(&array)
		print("code: \(code)")
		return code
	}
}
