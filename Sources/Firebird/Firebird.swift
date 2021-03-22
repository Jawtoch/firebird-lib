//
//  File.swift
//  
//
//  Created by ugo cottin on 20/03/2021.
//

public struct Firebird {
	public var name: String = "Hello, Firebird!"
	public var array: Array<ISC_STATUS> = Array(repeating: 0, count: Int(ISC_STATUS_LENGTH))
	
	public init() { }
	
	public var status: Int32 {
		var array = self.array
		let code = isc_sqlcode(&array)
		print("code: \(code)")
		return code
	}
}
