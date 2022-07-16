import CFirebird

/// Generic protocol used for all errors defined in the package.
public protocol FirebirdError: Error {
	
}

/// Represent an error thown by a Firebird C library function.
public struct FirebirdNativeError: FirebirdError, CustomStringConvertible {
	
	/// Length of the buffer used to retrieve strings from the status.
	public static var decodingBufferLength: Int16 = 1024 {
		willSet {
			if newValue > 0 {
				self.decodingBufferLength = newValue
			}
		}
	}
	
	/// Original status returned by the Firebird C library function.
	public let status: FirebirdStatus
	
	/// SQL error code of the error.
	public var sqlCode: Int32 {
		isc_sqlcode(status)
	}
	
	/// SQL string description of the error.
	public var sqlDescription: String {
		self.interprete(self.sqlCode) ?? "no description"
	}
	
	/// List of messages strings, giving details of the error.
	public var messages: [String] {
		self.getMessages()
	}
	
	public var description: String {
		"Error \(self.sqlCode): \(self.messages.joined(separator: ", "))"
	}
	
	
	/// Create an error based of a FirebirdStatus.
	/// - Parameter status: a FirebirdStatus containg an error.
	public init(status: FirebirdStatus) {
		self.status = status
	}
	
	/// Get a string description of a SQL error code
	/// - Parameter code: a SQL error code
	/// - Returns: the string description describing the SQL error code
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
	
	/// Get the messages detailing the error.
	/// - Returns: a list of messages strings giving detail of the error.
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
	
	/// Initialize a string using a closure.
	/// - Parameters:
	///   - length: length of the char buffer
	///   - encoding: string encoding
	///   - body: a closure with a char buffer as a parameter
	/// - Returns: the string made of the chars contained in the buffer, filled by the closure.
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
