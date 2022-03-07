//
//  File.swift
//  
//
//  Created by ugo cottin on 04/03/2022.
//

import fbclient

enum DatabaseParameter {
	case version1
	case username(_ username: String)
	case password(_ password: String)
	case dialect(_ dialect: SQLDialect)
}

enum SQLDialect: Int {
	case compatible = 1
	case diagnostic = 2
	case v6 = 3
}

extension DatabaseParameter: Hashable { }

public struct DatabaseParameters {
	
	public typealias Element = ISC_SCHAR
	
	private var options: [DatabaseParameter] = []
	
	public var buffer: [Element] {
		self.options.flatMap { self.getBytes(of: $0) }
	}
	
	mutating func append(contentOf sequence: [DatabaseParameter]) {
		for item in sequence {
			self.append(item)
		}
	}
	
	mutating func append(_ newParameter: DatabaseParameter) {
		if (!self.options.contains(newParameter)) {
			self.options.append(newParameter)
		}
	}
	
	private func getBytes(of parameter: DatabaseParameter) -> [Element] {
		var buffer = [Element]()
		switch parameter {
			case .version1:
				buffer.append(Element(isc_dpb_version1))
				
			case .username(let username):
				buffer.append(Element(isc_dpb_user_name))
				var usernameArray = username.utf8CString
				if (usernameArray.last == 0) {
					usernameArray.removeLast()
				}
				buffer.append(Element(usernameArray.count))
				buffer.append(contentsOf: usernameArray)
				
			case .password(let password):
				buffer.append(Element(isc_dpb_password))
				var passwordArray = password.utf8CString
				if (passwordArray.last == 0) {
					passwordArray.removeLast()
				}
				buffer.append(Element(passwordArray.count))
				buffer.append(contentsOf: passwordArray)
			case .dialect(let dialect):
				buffer.append(Element(isc_dpb_sql_dialect))
				buffer.append(1)
				buffer.append(Element(dialect.rawValue))
		}
		
		return buffer
	}
	
}
