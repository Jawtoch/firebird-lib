//
//  FirebirdDecoder.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

import Foundation

public class FirebirdDecoder {
	
	public func decode<T>(_ type: T.Type, from data: Data?, context: FirebirdCodingContext) throws -> T where T: Decodable {
		let decoder = _FirebirdDecoder(context: context, data: data)
		let value = try T.init(from: decoder)
		
		return value
	}
	
}

internal class _FirebirdDecoder: Decoder {

	var codingPath: [CodingKey]
	
	var userInfo: [CodingUserInfoKey : Any]
	
	var context: FirebirdCodingContext
	
	var storage: Data?
	
	init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey : Any] = [:], context: FirebirdCodingContext, data: Data?) {
		self.codingPath = codingPath
		self.userInfo = userInfo
		self.context = context
		self.storage = data
	}
	
	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
		fatalError("Non implemented")
	}
	
	func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		fatalError("Non implemented")
	}
	
	func singleValueContainer() throws -> Swift.SingleValueDecodingContainer {
		let container = FirebirdSingleValueDecodingContainer(codingPath: self.codingPath, context: self.context, data: self.storage)
		
		return container
	}
	
}

extension _FirebirdDecoder: FirebirdDecodingContainer {
	
	var data: Data? {
		self.storage
	}
	
}
