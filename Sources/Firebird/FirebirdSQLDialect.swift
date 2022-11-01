import CFirebird

public struct FirebirdSQLDialect: RawRepresentable {
    
    public typealias RawValue = UInt16
    
    public static let v5 = Self(rawValue: Self.RawValue(SQL_DIALECT_V5))
    
    public static let v6 = Self(rawValue: Self.RawValue(SQL_DIALECT_V6))
    
    public static let v6Transition = Self(rawValue: Self.RawValue(SQL_DIALECT_V6_TRANSITION))
    
    public static let current = Self(rawValue: Self.RawValue(SQL_DIALECT_CURRENT))
    
    public var rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
}
