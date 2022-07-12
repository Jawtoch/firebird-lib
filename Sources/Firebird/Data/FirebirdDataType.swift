import CFirebird

/// Enumeration of available SQL data types
public struct FirebirdDataType: RawRepresentable {
	
	public typealias RawValue = Int32
	
	/// String of fixed length.
	public static let text = FirebirdDataType(SQL_TEXT)
	
	/// String of variable length.
	public static let varying = FirebirdDataType(SQL_VARYING)
	
	/// Signed integer of 16 bits.
	public static let int16 = FirebirdDataType(SQL_SHORT)
	
	/// Signed integer of 32 bits or 64bits, depend of your platform.
	public static let int = FirebirdDataType(SQL_LONG)
	
	public static let int64 = FirebirdDataType(SQL_INT64)
	
	public static let float = FirebirdDataType(SQL_FLOAT)
	
	public static let double = FirebirdDataType(SQL_DOUBLE)
		
	public static let d_float = FirebirdDataType(SQL_D_FLOAT)
	
	/// Date and time
	public static let timestamp = FirebirdDataType(SQL_TIMESTAMP)
	
	public static let blob = FirebirdDataType(SQL_BLOB)
	
	public static let array = FirebirdDataType(SQL_ARRAY)
	
	public static let quad = FirebirdDataType(SQL_QUAD)
	
	/// Time only
	public static let timeOnly = FirebirdDataType(SQL_TYPE_TIME)
	
	/// Date only
	public static let dateOnly = FirebirdDataType(SQL_TYPE_DATE)
	
	public static let null = FirebirdDataType(SQL_NULL)
	
	public let rawValue: Int32
	
	public var isNullable: Bool {
		(self.rawValue & 1) != 0
	}
	
	private init(_ rawValue: RawValue) {
		self.rawValue = rawValue
	}
	
	public init(rawValue: RawValue) {
		self.init(rawValue)
	}
	
	public init?(rawValue: Int16) {
		guard let shortValue = RawValue(exactly: rawValue) else {
			return nil
		}
		
		self.init(rawValue: shortValue)
	}
}

extension FirebirdDataType: Equatable {
	
	public static func == (lhs: Self, rhs: Self) -> Bool {
		(lhs.rawValue & ~1) == (rhs.rawValue & ~1)
	}
	
}

extension FirebirdDataType: CustomStringConvertible {
	
	public var sqlName: String {
		switch self {
			case .text: return "TEXT"
			case .varying: return "VARYING"
			case .int16: return "SHORT"
			case .int: return "LONG"
			case .float: return "FLOAT"
			case .double: return "DOUBLE"
			case .d_float: return "D_FLOAT"
			case .timestamp: return "TIMESTAMP"
			case .blob: return "BLOB"
			case .array: return "ARRAY"
			case .quad: return "QUAD"
			case .timeOnly: return "TIME"
			case .dateOnly: return "DATE"
			case .int64: return "INT64"
			case .null: return "NULL"
			default: return "UNKNOWN"
		}
	}
	
	public var description: String {
		"\(self.sqlName)\(self.isNullable ? "?" : "")"
	}
	
}

