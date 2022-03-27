//
//  FirebirdUsernameConnectionParameter.swift
//  
//
//  Created by ugo cottin on 09/03/2022.
//

import fbclient

struct FirebirdUsernameConnectionParameter: FirebirdConnectionParameter {
	
	public let username: String
	
	public var description: String {
		"Username \(self.username)"
	}
	
	public var rawBytes: [ISC_SCHAR] {
		var _buffer = [ISC_SCHAR]()
		_buffer.append(ISC_SCHAR(isc_dpb_user_name))
		var usernameArray = self.username.utf8CString
		if (usernameArray.last == 0) {
			usernameArray.removeLast()
		}
		_buffer.append(ISC_SCHAR(usernameArray.count))
		_buffer.append(contentsOf: usernameArray)
		return _buffer
	}
	
	public init(_ username: String) {
		self.username = username
	}
}
