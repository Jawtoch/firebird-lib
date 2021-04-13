//
//  FirebirdDataType.swift
//  
//
//  Created by Ugo Cottin on 10/03/2021.
//

public struct FirebirdDataType: RawRepresentable, Equatable {
	
	public typealias RawValue = Int32
	
	/// String of fixed length
	public static let text = FirebirdDataType(452)
	
	/// String of variable length
	public static let varying = FirebirdDataType(448)
	
	/// Signed integer of 16 bits
	public static let short = FirebirdDataType(500)
	
	/// Signed integer of 32 bits
	public static let long = FirebirdDataType(496)
	
	public static let float = FirebirdDataType(482)
	
	public static let double = FirebirdDataType(480)
	
	public static let d_float = FirebirdDataType(530)
	
	/// Date and time
	public static let timestamp = FirebirdDataType(510)
	
	public static let blob = FirebirdDataType(520)
	
	public static let array = FirebirdDataType(540)
	
	public static let quad = FirebirdDataType(550)
	
	/// Time only
	public static let time = FirebirdDataType(560)
	
	/// Date only
	public static let date = FirebirdDataType(570)
	
	public static let int64 = FirebirdDataType(580)
	
	public static let null = FirebirdDataType(32766)
	
	public let rawValue: Int32
	
	public init(_ rawValue: RawValue) {
		self.rawValue = rawValue & ~1
	}
	
	public init?(rawValue: Int32) {
		self.init(rawValue)
	}
	
	public init?(rawValue: Int16) {
		self.init(Int32(rawValue))
	}
}

extension FirebirdDataType: CustomStringConvertible {
	var sqlName: String {
		switch self {
			case .text: return "TEXT"
			case .varying: return "VARYING"
			case .short: return "SHORT"
			case .long: return "LONG"
			case .float: return "FLOAT"
			case .double: return "DOUBLE"
			case .d_float: return "D_FLOAT"
			case .timestamp: return "TIMESTAMP"
			case .blob: return "BLOB"
			case .array: return "ARRAY"
			case .quad: return "QUAD"
			case .time: return "TIME"
			case .date: return "DATE"
			case .int64: return "INT64"
			case .null: return "NULL"
			default: return "UNKNOWN"
		}
	}
	
	public var description: String {
		return self.sqlName
	}
}
