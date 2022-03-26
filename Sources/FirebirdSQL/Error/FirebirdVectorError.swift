//
//  FirebirdVectorError.swift
//  
//
//  Created by ugo cottin on 15/03/2022.
//

import fbclient

public struct FirebirdVectorError {
	
	public static var vector: [ISC_STATUS] {
		Array(repeating: .zero, count: Int(ISC_STATUS_LENGTH))
	}
	
	public let sqlCode: Int32
	
	public let sqlMessage: String
	
	public let message: String
	
	public let detais: [String]
	
	public let vector: [ISC_STATUS]
	
	public init(from vector: [ISC_STATUS]) {
		self.vector = vector
		var vector = vector
		let sqlCode = isc_sqlcode(&vector)
		self.sqlCode = sqlCode
		
		let messageSize: Int16 = 512
		var messageBuffer = Array<CChar>(repeating: .zero, count: Int(messageSize))
		self.sqlMessage = withUnsafeMutablePointer(to: &messageBuffer[0]) { messagePointer -> String in
			isc_sql_interprete(Int16(sqlCode), messagePointer, messageSize)
			return String(cString: messagePointer)
		}
		
		let messages = withUnsafePointer(to: &vector[0]) { vectorPointer -> [String] in
			var vectorPointer = Optional(vectorPointer)
			return withUnsafeMutablePointer(to: &vectorPointer) { pvector in
				withUnsafeMutablePointer(to: &messageBuffer[0]) { messagePointer in
					var messages: [String] = []
					
					while fb_interpret(messagePointer, UInt32(messageSize), pvector) > 0 {
						messages.append("\(String(cString: messagePointer))")
					}
					
					return messages
				}
			}
		}
		
		self.message = messages.first ?? ""
		self.detais = Array(messages.dropFirst())
	}
}

extension FirebirdVectorError: FirebirdError {
	
	public var reason: String {
		self.message
	}
	
	public var description: String {
		"""
		Error \(self.sqlCode): \(self.sqlMessage)
		Reason: \(self.reason)
		Details:
		\(self.detais.map({ "- \($0)" }).joined(separator: "\n"))
		"""
	}
	
}
