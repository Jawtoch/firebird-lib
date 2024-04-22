import CFirebird
import Foundation

public class FBDecoder: FirebirdDecoder {
    
    public init() { }
    
    public func decode<T>(_ type: T.Type, from data: FirebirdData) throws -> T where T : Decodable {
        let decoder = FBDecoderImpl(data: data, codingPath: [])
        let decoded = try type.init(from: decoder)
        
        return decoded
    }
    
}

class FBDecoderImpl: Decoder {
        
    let codingPath: [CodingKey]
    
    let userInfo: [CodingUserInfoKey : Any] = [:]
    
    let data: FirebirdData
    
    init(data: FirebirdData, codingPath: [CodingKey]) {
        self.data = data
        self.codingPath = codingPath
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        fatalError("not implemented")
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("not implemented")
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        FBDecoderSingleValueDecodingContainer(data: self.data, codingPath: self.codingPath, superDecoder: self)
    }
    
}

internal class FBDecoderSingleValueDecodingContainer: SingleValueDecodingContainer {
    
    let codingPath: [CodingKey]
    
    let data: FirebirdData
    
    let superDecoder: Decoder
    
    init(data: FirebirdData, codingPath: [CodingKey], superDecoder: Decoder) {
        self.data = data
        self.codingPath = codingPath
        self.superDecoder = superDecoder
    }
    
    func decodeNil() -> Bool {
        self.data.value == nil
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        fatalError("not implemented")
    }
    
    func decode(_ type: String.Type) throws -> String {
        switch(self.data.type) {
        case .varying:
            return try _decodeVaryingAsString(data: self.data)
        case .text:
            return try _decodeTextAsString(data: self.data)
        default:
            fatalError("not implemented")
        }
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        switch self.data.type {
        case .dateOnly, .timeOnly, .timestamp:
            return try _decodeAnyDateAsDouble(data: self.data)
        case .long:
            return try _decodeLongAsDouble(data: self.data)
        case .int64:
            return try SQLInt64(from: self.data).doubleValue()
        default:
            fatalError("not implemented")
        }
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        fatalError("not implemented")
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        switch (self.data.type) {
        case .int16:
            return Int(try self.decode(Int16.self))
        case .long:
            guard let value = self.data.value else {
                fatalError("not implemented")
            }
            
            let bits = value.count * 8
            
            switch bits {
            case Int32.bitWidth:
                return Int(try self.decode(Int32.self))
            case Int64.bitWidth:
                return Int(try self.decode(Int64.self))
            default:
                fatalError("not implemented")
            }
        case .int64:
            return Int(try self.decode(Int64.self))
        default:
            fatalError("not implemented")
        }
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        fatalError("not implemented")
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        guard let data = self.data.value else {
            fatalError("not implemented")
        }
        
        let decoded = data.withUnsafeBytes { unsafeData in
            unsafeData.load(as: Int16.self)
        }
        
        return decoded
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        guard let data = self.data.value else {
            fatalError("not implemented")
        }
        
        let decoded = data.withUnsafeBytes { unsafeData in
            unsafeData.load(as: Int32.self)
        }
        
        return decoded
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        guard let data = self.data.value else {
            fatalError("not implemented")
        }
        
        let decoded = data.withUnsafeBytes { unsafeData in
            unsafeData.load(as: Int64.self)
        }
        
        return decoded
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        fatalError("not implemented")
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        fatalError("not implemented")
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        fatalError("not implemented")
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        fatalError("not implemented")
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        fatalError("not implemented")
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try type.init(from: self.superDecoder)
    }
    
}

fileprivate func _decodeLongAsDouble(data: FirebirdData) throws -> Double {
    guard let bytes = data.value else {
        fatalError("not implemented")
    }
    
    let intValue = Double(bytes.withUnsafeBytes { unsafeBytes in
        unsafeBytes.load(as: Int32.self)
    })
    
    let scale = fabs(Double(data.scale))
    let multiplier = pow(10.0, scale)
    
    let value = intValue / multiplier
    
    return value
}

fileprivate func _decodeTextAsString(data: FirebirdData) throws -> String {
    guard let data = data.value else {
        fatalError("not implemented")
    }
    
    guard let value = String(data: data, encoding: .utf8) else {
        fatalError("not implemented")
    }
    
    return value
}

fileprivate func _decodeVaryingAsString(data: FirebirdData) throws -> String {
    guard let data = data.value else {
        fatalError("not implemented")
    }
    
    let size = data.withUnsafeBytes { unsafeData in
        Int(unsafeData.load(fromByteOffset: 0, as: Int16.self))
    }
    
    let startIndex = data.startIndex + Int16.bitWidth / 8
    guard startIndex + size <= data.endIndex else {
        fatalError("not implemented")
    }
    
    let payload = data[startIndex ..< startIndex + size]
    
    guard let value = String(data: payload, encoding: .utf8) ?? String(data: payload, encoding: .ascii) else {
        fatalError("not implemented")
    }
    
    return value
}

fileprivate func _decodeAnyDateAsDouble(data: FirebirdData) throws -> Double {
    guard let bytes = data.value else {
        fatalError("not implemented")
    }
    
    var timeInfo: tm
    switch data.type {
    case .dateOnly:
        timeInfo = _decodeSQLDateAsTm(bytes: bytes)
    case .timeOnly:
        timeInfo = _decodeSQLTimeAsTm(bytes: bytes)
    case .timestamp:
        timeInfo = _decodeTimestampAsTm(bytes: bytes)
    default:
        fatalError("not implemented")
    }
    
    let rawTime = timegm(&timeInfo)
    let timeInterval = TimeInterval(rawTime)
    let offset = Date.timeIntervalBetween1970AndReferenceDate
    
    return timeInterval - offset
}

fileprivate func _decodeTimestampAsTm(bytes: Data) -> tm {
    var timestamp = bytes.withUnsafeBytes {
        $0.load(as: ISC_TIMESTAMP.self)
    }
    
    var timeInfo: tm = tm()
    isc_decode_timestamp(&timestamp, &timeInfo)
    
    return timeInfo
}

fileprivate func _decodeSQLDateAsTm(bytes: Data) -> tm {
    var sqlDate = bytes.withUnsafeBytes {
        $0.load(as: ISC_DATE.self)
    }
    
    var timeInfo: tm = tm()
    isc_decode_sql_date(&sqlDate, &timeInfo)
    
    return timeInfo
}

fileprivate func _decodeSQLTimeAsTm(bytes: Data) -> tm {
    var sqlTime = bytes.withUnsafeBytes {
        $0.load(as: ISC_TIME.self)
    }
    
    var timeInfo: tm = tm()
    isc_decode_sql_time(&sqlTime, &timeInfo)
    
    return timeInfo
}

protocol SQLDataType {
    
    init(from data: FirebirdData) throws
    
    func doubleValue() throws -> Double
    
}

struct SQLInt64: SQLDataType {
    
    let data: FirebirdData
    
    let value: Int64
    
    init(from data: FirebirdData) throws {
        self.data = data
        
        guard let bytes = self.data.value else {
            fatalError("not implemented")
        }
        
        self.value = bytes.withUnsafeBytes { $0.load(as: Int64.self) }
    }
    
    func doubleValue() throws -> Double {
        let scale = fabs(Double(self.data.scale))
        let multiplier = pow(10.0, scale)
        return Double(self.value) / multiplier
    }
    
}
