//
//  FirebirdError.swift
//  
//
//  Created by ugo cottin on 24/06/2022.
//

import CFirebird

public typealias FirebirdStatus = [ISC_STATUS]

public protocol Factory {
	
	associatedtype Produced
	
	func next() -> Produced
	
}

public struct FirebirdStatusFactory: Factory {
	
	public typealias Produced = FirebirdStatus
	
	public static var statusLength: Int {
		Int(ISC_STATUS_LENGTH)
	}
	
	public static var shared: Self {
		if let instance = self.instance {
			return instance
		}
		
		let new = FirebirdStatusFactory()
		self.instance = new
		
		return new
	}
	
	private static var instance: FirebirdStatusFactory?
	
	public func next() -> FirebirdStatus {
		.init(repeating: 0, count: Self.statusLength)
	}
}

public enum FirebirdError: Error {
	case error
}

func withStatus(_ closure: (inout FirebirdStatus) throws -> ()) throws {
	var status = FirebirdStatusFactory.shared.next()
	try closure(&status)
	if status[0] == 1 && status[1] > 0 {
		throw FirebirdNativeError(status: status)
	}
}

public struct FirebirdNativeError: Error, CustomStringConvertible {
	
	public static var decodingBufferLength: Int16 = 1024 {
		willSet {
			if newValue > 0 {
				self.decodingBufferLength = newValue
			}
		}
	}
	
	public let status: FirebirdStatus
	
	public var sqlCode: Int32 {
		isc_sqlcode(status)
	}
	
	public var sqlDescription: String {
		self.interprete(self.sqlCode) ?? "no description"
	}
	
	public var messages: [String] {
		self.getMessages()
	}
	
	public var description: String {
		"Error \(self.sqlCode): \(self.messages.joined(separator: ", "))"
	}
	
	public init(status: FirebirdStatus) {
		self.status = status
	}
	
	private func interprete(_ code: Int32) -> String? {
		guard let _code = Int16(exactly: code) else {
			return nil
		}
		
		let bufferLength = Self.decodingBufferLength
		var buffer: [ISC_SCHAR] = Array(repeating: 0, count: Int(bufferLength))
		
		return buffer.withUnsafeMutableBufferPointer { unsafeBuffer -> String? in
			guard let baseAddress = unsafeBuffer.baseAddress else {
				return nil
			}
			
			isc_sql_interprete(_code, baseAddress, bufferLength)
			return String(cString: baseAddress, encoding: .utf8)
		}
	}
	
	private func getMessages() -> [String] {
		self.status.withUnsafeBufferPointer { unsafeStatus in
			var baseAddress = unsafeStatus.baseAddress
			return withUnsafeMutablePointer(to: &baseAddress) { unsafeBaseAddress in
				var keepInterpreting = true
				var messages: [String] = []
				while keepInterpreting {
					let message = String.fromCString(length: Int(Self.decodingBufferLength)) { unsafeString in
						keepInterpreting = fb_interpret(unsafeString, UInt32(Self.decodingBufferLength), unsafeBaseAddress) > 0
					}
					if let message = message {
						messages.append(message)
					}
				}
				
				return messages
			}
		}
	}
	
	
}

private extension String {
	
	static func fromCString(length: Int, encoding: Self.Encoding = .utf8, _ body: (UnsafeMutablePointer<CChar>) throws -> ()) rethrows -> Self? {
		var buffer: [CChar] = Array(repeating: 0, count: length)
		try buffer.withUnsafeMutableBufferPointer { unsafeBuffer in
			guard let baseAddress = unsafeBuffer.baseAddress else {
				return
			}
			
			try body(baseAddress)
		}
		
		return Self.init(cString: buffer, encoding: encoding)
	}
	
}
