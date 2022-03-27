//
//  FirebirdPasswordConnectionParameter.swift
//
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

public struct FirebirdPasswordConnectionParameter: FirebirdConnectionParameter {
	
	private let password: String
	
	public var description: String {
		"Password \(String(repeating: "*", count: self.password.count))"
	}
	
	public var rawBytes: [ISC_SCHAR] {
		var _buffer = [ISC_SCHAR]()
		_buffer.append(ISC_SCHAR(isc_dpb_password))
		var passwordArray = self.password.utf8CString
		if (passwordArray.last == 0) {
			passwordArray.removeLast()
		}
		_buffer.append(ISC_SCHAR(passwordArray.count))
		_buffer.append(contentsOf: passwordArray)
		return _buffer
	}
	
	public init(_ password: String) {
		self.password = password
	}
}
