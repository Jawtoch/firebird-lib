//
//  FirebirdDecoder.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

import Foundation

class FirebirdDecoder {
	
	func decode<T>(_ type: T.Type, from data: Data?, context: CodingContext) throws -> T where T: Decodable {
		let decoder = _FirebirdDecoder(context: context, data: data)
		let value = try T.init(from: decoder)
		
		return value
	}
	
}

class _FirebirdDecoder: Decoder, DecodingContainer {

	var codingPath: [CodingKey]
	
	var userInfo: [CodingUserInfoKey : Any]
	
	var context: CodingContext
	
	var data: Data?
	
	init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey : Any] = [:], context: CodingContext, data: Data?) {
		self.codingPath = codingPath
		self.userInfo = userInfo
		self.context = context
		self.data = data
	}
	
	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
		fatalError("Non implemented")
	}
	
	func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		fatalError("Non implemented")
	}
	
	func singleValueContainer() throws -> Swift.SingleValueDecodingContainer {
		let container = _SingleValueDecodingContainer(codingPath: self.codingPath, context: self.context, data: self.data)
		
		return container
	}
	
}
