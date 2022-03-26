//
//  FirebirdEncoder.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

import Foundation

class FirebirdEncoder {
	
	func encode<T>(_ value: T, context: CodingContext) throws -> Data? where T: Encodable {
		let encoder = _FirebirdEncoder(context: context)
		try value.encode(to: encoder)
		
		return encoder.data
	}
	
}

class _FirebirdEncoder: Encoder {
	
	var codingPath: [CodingKey]
	
	var userInfo: [CodingUserInfoKey : Any]
	
	var context: CodingContext
	
	var container: EncodingContainer? {
		willSet {
			precondition(self.container == nil)
		}
	}
	
	init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey : Any] = [:], context: CodingContext) {
		self.codingPath = codingPath
		self.userInfo = userInfo
		self.context = context
	}
	
	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
		fatalError()
	}
	
	func unkeyedContainer() -> UnkeyedEncodingContainer {
		fatalError()
	}
	
	func singleValueContainer() -> SingleValueEncodingContainer {
		let container = SingleValueContainer(codingPath: self.codingPath, context: self.context)
		self.container = container
		
		return container
	}
}

extension _FirebirdEncoder: EncodingContainer {
	
	var data: Data? {
		self.container?.data
	}
	
}
