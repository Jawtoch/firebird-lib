//
//  FirebirdDataType.swift
//  
//
//  Created by Ugo Cottin on 19/03/2022.
//

import fbclient

struct FirebirdDataType: RawRepresentable, Equatable {
	
	typealias RawValue = Int32
	
	/// String of fixed length
	static let text = FirebirdDataType(SQL_TEXT)
	
	/// String of variable length
	static let varying = FirebirdDataType(SQL_VARYING)
	
	/// Signed integer of 16 bits
	static let short = FirebirdDataType(SQL_SHORT)
	
	/// Signed integer of 32 bits
	static let long = FirebirdDataType(SQL_LONG)
	
	static let float = FirebirdDataType(SQL_FLOAT)
	
	static let double = FirebirdDataType(SQL_DOUBLE)
	
	static let d_float = FirebirdDataType(SQL_D_FLOAT)
	
	/// Date and time
	static let timestamp = FirebirdDataType(SQL_TIMESTAMP)
	
	static let blob = FirebirdDataType(SQL_BLOB)
	
	static let array = FirebirdDataType(SQL_ARRAY)
	
	static let quad = FirebirdDataType(SQL_QUAD)
	
	/// Time only
	static let time = FirebirdDataType(SQL_TYPE_TIME)
	
	/// Date only
	static let date = FirebirdDataType(SQL_TYPE_DATE)
	
	static let int64 = FirebirdDataType(SQL_INT64)
	
	static let null = FirebirdDataType(SQL_NULL)
	
	let rawValue: Int32
	
	var isNullable: Bool {
		(self.rawValue & 1) != 0
	}
	
	private init(_ rawValue: RawValue) {
		self.rawValue = rawValue
	}
	
	init(rawValue: RawValue) {
		self.init(rawValue)
	}
	
	init?(rawValue: Int16) {
		guard let shortValue = RawValue(exactly: rawValue) else {
			return nil
		}
		
		self.init(rawValue: shortValue)
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
