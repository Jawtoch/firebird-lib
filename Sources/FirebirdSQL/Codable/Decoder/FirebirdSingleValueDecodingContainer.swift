//
//  FirebirdSingleValueDecodingContainer.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

import Foundation

internal class FirebirdSingleValueDecodingContainer {
	
	var codingPath: [CodingKey]
	
	var context: FirebirdCodingContext
	
	var storage: Data?
	
	init(codingPath: [CodingKey], context: FirebirdCodingContext, data: Data?) {
		self.codingPath = codingPath
		self.context = context
		self.storage = data
	}
	
}

extension FirebirdSingleValueDecodingContainer: FirebirdDecodingContainer {
	
	var data: Data? {
		self.storage
	}
	
}

extension FirebirdSingleValueDecodingContainer: SingleValueDecodingContainer {
	
	func decodeNil() -> Bool {
		fatalError("Non implemented")
	}
	
	func decode(_ type: Bool.Type) throws -> Bool {
		fatalError("Non implemented")
	}
	
	func decode(_ type: String.Type) throws -> String {
		guard let data = self.storage else {
			let context = DecodingError.Context(
				codingPath: self.codingPath,
				debugDescription: "Unable to decode non optional String from nil data")
			throw DecodingError.typeMismatch(type, context)
		}
		
		let stringValue: String
		switch self.context.dataType {
			case .varying:
				let sizeBytes = data.prefix(2)
				let size = Int(sizeBytes.withUnsafeBytes { $0.load(as: Int16.self) })
				let buffer = data
					.dropFirst(2)
					.prefix(size)
				guard let _stringValue = String(bytes: buffer, encoding: .utf8) else {
					let context = DecodingError.Context(
						codingPath: self.codingPath,
						debugDescription: "Unable to decode String with utf8 encoding")
					throw DecodingError.typeMismatch(type, context)
				}
				
				stringValue = _stringValue
			default:
				let context = DecodingError.Context(
					codingPath: self.codingPath,
					debugDescription: "Unable to decode String from type \(self.context.dataType)")
				throw DecodingError.typeMismatch(type, context)
		}
		
		return stringValue
	}
	
	func decode(_ type: Double.Type) throws -> Double {
		fatalError("Non implemented")
	}
	
	func decode(_ type: Float.Type) throws -> Float {
		fatalError("Non implemented")
	}
	
	func decode(_ type: Int.Type) throws -> Int {
		fatalError("Non implemented")
	}
	
	func decode(_ type: Int8.Type) throws -> Int8 {
		fatalError("Non implemented")
	}
	
	func decode(_ type: Int16.Type) throws -> Int16 {
		guard self.context.size * 8 == Int16.bitWidth else {
			let context = DecodingError.Context(
				codingPath: self.codingPath,
				debugDescription: "Unable to decode Int16, context require \(self.context.size * 8) bits")
			throw DecodingError.typeMismatch(type, context)
		}
		
		guard let data = self.storage else {
			let context = DecodingError.Context(
				codingPath: self.codingPath,
				debugDescription: "Unable to decode non optional Int16 from nil data")
			throw DecodingError.typeMismatch(type, context)
		}
		
		let intValue = data.withUnsafeBytes { $0.load(as: Int16.self) }
		return intValue
	}
	
	func decode(_ type: Int32.Type) throws -> Int32 {
		fatalError("Non implemented")
	}
	
	func decode(_ type: Int64.Type) throws -> Int64 {
		fatalError("Non implemented")
	}
	
	func decode(_ type: UInt.Type) throws -> UInt {
		fatalError("Non implemented")
	}
	
	func decode(_ type: UInt8.Type) throws -> UInt8 {
		fatalError("Non implemented")
	}
	
	func decode(_ type: UInt16.Type) throws -> UInt16 {
		fatalError("Non implemented")
	}
	
	func decode(_ type: UInt32.Type) throws -> UInt32 {
		fatalError("Non implemented")
	}
	
	func decode(_ type: UInt64.Type) throws -> UInt64 {
		fatalError("Non implemented")
	}
	
	func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		fatalError("Non implemented")
	}
	
	
}
