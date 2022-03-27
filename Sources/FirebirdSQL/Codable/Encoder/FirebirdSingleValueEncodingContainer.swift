//
//  FirebirdSingleValueEncodingContainer.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

import Foundation

class FirebirdSingleValueEncodingContainer {
		
	var codingPath: [CodingKey]
	
	var context: FirebirdCodingContext
	
	var storage: Data?
	
	private var canEncodeNewValue: Bool
	
	init(codingPath: [CodingKey], context: FirebirdCodingContext) {
		self.codingPath = codingPath
		self.context = context
		self.storage = nil
		self.canEncodeNewValue = true
	}
	
	private func canEncode(value: Any?) throws {
		guard self.canEncodeNewValue else {
			let context = EncodingError.Context(
				codingPath: self.codingPath,
				debugDescription: "Cannot encode multiples values")
			throw EncodingError.invalidValue(value as Any, context)
		}
	}
	
}

extension FirebirdSingleValueEncodingContainer: FirebirdEncodingContainer {
	
	var data: Data? {
		self.storage
	}
	
}

extension FirebirdSingleValueEncodingContainer: SingleValueEncodingContainer {
	func encodeNil() throws {
		try self.canEncode(value: nil)
		
		guard self.context.dataType.isNullable else {
			let context = EncodingError.Context(
				codingPath: self.codingPath,
				debugDescription: "Nil value not allowed")
			throw EncodingError.invalidValue((nil as Any?) as Any, context)
		}
		
		self.storage = nil
		self.canEncodeNewValue = false
	}
	
	func encode(_ value: Bool) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: String) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: Double) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: Float) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: Int) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: Int8) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: Int16) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: Int32) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: Int64) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: UInt) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: UInt8) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: UInt16) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: UInt32) throws {
		fatalError("Non implemented")
	}
	
	func encode(_ value: UInt64) throws {
		fatalError("Non implemented")
	}
	
	func encode<T>(_ value: T) throws where T : Encodable {
		fatalError("Non implemented")
	}
	
	
}
