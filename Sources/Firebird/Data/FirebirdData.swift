//
//  File.swift
//  
//
//  Created by Ugo Cottin on 10/03/2021.
//

import Foundation

public struct FirebirdData {

	/// Type of the data
	public let type: FirebirdDataType
	
	/// Scale of data, used by numerics types.
	/// For example, a value of `1024` with scale of `-2` represent `10.24`.
	/// A scale of `0` mean that the number is not numeric.
	public let scale: Int
	
	/// Subtype of the blob. Used only by blobs
	public let subtype: Int
	
	/// Length of the data
	public let length: Int
	
	/// Bytes of data, if not null
	public let value: Data?
	
	/// Return the decoded value
	public var decodedValue: Any? {
		switch self.type {
			case .text, .varying:
				return self.string
			case .short:
				return self.short
			case .long:
				return self.long
			case .timestamp, .date:
				return self.date
			case .int64:
				return self.int64
			default:
				return nil
		}
	}
	
	/// Create a data structure for encoding / decoding data.
	/// - Parameters:
	///   - type: type of the data
	///   - scale: scale of the data (negative), if numeric, else 0
	///   - subtype: if blob, the subtype of data
	///   - length: the length of the data. If not set, the number of bytes in `value` will be used instead.
	///   - value: the bytes of the data.
	public init(type: FirebirdDataType, scale: Int = 0, subtype: Int = 0, length: Int? = nil, value: Data? = nil) {
		self.type = type
		self.scale = scale
		self.subtype = subtype
		self.length = length ?? value?.count ?? 0
		self.value = value
	}
	
}

extension FirebirdData: CustomStringConvertible {
	public var description: String {
		guard let value = self.value else {
			return "<null>"
		}
		
		var description: String?
		switch self.type {
			case .text, .varying:
				description = self.string?.description
				if description != nil, description!.isEmpty {
					description = "<empty>"
				}
			case .short:
				description = self.short?.description
			case .long:
				description = self.long?.description
			case .timestamp, .date:
				description = self.date?.description
			case .int64:
				if let doubleValue = self.int64 {
					description = String(format: "%.\(abs(self.scale))f", doubleValue)
				} else {
					description = nil
				}
//			case .blob:
//				description = self.blob?.description
			default:
				description = nil
		}
		
		if let description = description {
			return description
		}
		
		return "\(self.type) \(value)"
	}
}

extension FirebirdData {
	
	public var string: String? {
		
		guard let value = self.value else {
			return nil
		}
		
		if let str = String(data: value, encoding: .utf8) {
			return str.trimmingCharacters(in: ["\0", " ", "\n", "\r", "\t"])
		}
		
		return nil
	}
	
}

extension FirebirdData {
	
	public var date: Date? {
		
		guard var value = self.value else {
			return nil
		}
		
		let tm_time = withUnsafePointer(to: &value) { pointer in
			pointer.withMemoryRebound(to: ISC_TIMESTAMP.self, capacity: 1) { datePointer -> tm in
				var tm_time = tm()
				isc_decode_timestamp(datePointer, &tm_time)
				
				return tm_time
			}
		}
	
		return Date(tm_time: tm_time)
	}
}
public extension Date {
	
	/// Initialize a date from a `tm_time` structure
	/// - Parameter tm_time: a `tm_time` structure
	init(tm_time: tm) {
		var copy = tm_time
		let timestamp = timegm(&copy)
		self.init(timeIntervalSince1970: TimeInterval(timestamp))
	}
	
	/// Get the `tm_time` structure associated to this date
	var tm_time: tm {
		var timestamp: time_t = Int(self.timeIntervalSince1970)
		let c_time: tm = withUnsafePointer(to: &timestamp) { time_ptr in
			localtime(time_ptr).pointee
		}
		
		return c_time
	}
}

extension FirebirdData {
	
	public var int64: Double? {
		// Decimal
		guard let value = self.long else {
			return nil
		}
		let scale = pow(10.0, fabs(Double(self.scale)))
		
		return (Double(value) / scale)
	}
	
	public var short: Int16? {
		guard let value = self.value else {
			return nil
		}
		
		let cint = value.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
			buffer.bindMemory(to: CShort.self).first
		}
		
		if let cint = cint {
			return Int16(cint)
		}
		
		return nil
	}
	
	public var long: Int? {
		guard let value = self.value else {
			return nil
		}
		
		let cint = value.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
			buffer.bindMemory(to: Int32.self).first
		}
		
		if let cint = cint {
			return Int(cint)
		}
		
		return nil
	}
	
}
