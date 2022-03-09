//
//  UsernameFirebirdDatabaseOption.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

struct UsernameFirebirdDatabaseOption: FirebirdDatabaseOption {
	
	private let username: String
	
	var description: String {
		"Username \(self.username)"
	}
	
	var buffer: [Element] {
		var _buffer = [Element]()
		_buffer.append(Element(isc_dpb_user_name))
		var usernameArray = self.username.utf8CString
		if (usernameArray.last == 0) {
			usernameArray.removeLast()
		}
		_buffer.append(Element(usernameArray.count))
		_buffer.append(contentsOf: usernameArray)
		return _buffer
	}
	
	init(_ username: String) {
		self.username = username
	}
}
