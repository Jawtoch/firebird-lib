//
//  PasswordFirebirdDatabaseOption.swift
//
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

struct PasswordFirebirdDatabaseOption: FirebirdDatabaseOption {
	
	private let password: String
	
	var description: String {
		"Password \(String(repeating: "*", count: self.password.count))"
	}
	
	var buffer: [Element] {
		var _buffer = [Element]()
		_buffer.append(Element(isc_dpb_password))
		var passwordArray = self.password.utf8CString
		if (passwordArray.last == 0) {
			passwordArray.removeLast()
		}
		_buffer.append(Element(passwordArray.count))
		_buffer.append(contentsOf: passwordArray)
		return _buffer
	}
	
	init(_ password: String) {
		self.password = password
	}
}
