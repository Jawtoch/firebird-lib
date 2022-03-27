//
//  FirebirdEncoder.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

import Foundation

public class FirebirdEncoder {
	
	public func encode<T>(_ value: T, context: FirebirdCodingContext) throws -> Data? where T: Encodable {
		let encoder = _FirebirdEncoder(context: context)
		try value.encode(to: encoder)
		
		return encoder.data
	}
	
}

internal class _FirebirdEncoder: Encoder {
	
	var codingPath: [CodingKey]
	
	var userInfo: [CodingUserInfoKey : Any]
	
	var context: FirebirdCodingContext
	
	var container: FirebirdEncodingContainer? {
		willSet {
			precondition(self.container == nil)
		}
	}
	
	init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey : Any] = [:], context: FirebirdCodingContext) {
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
		let container = FirebirdSingleValueEncodingContainer(codingPath: self.codingPath, context: self.context)
		self.container = container
		
		return container
	}
}

extension _FirebirdEncoder: FirebirdEncodingContainer {
	
	var data: Data? {
		self.container?.data
	}
	
}
