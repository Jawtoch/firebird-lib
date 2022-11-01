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
        FBDecoderSingleValueDecodingContainer(data: self.data, codingPath: self.codingPath)
    }
    
}

internal class FBDecoderSingleValueDecodingContainer: SingleValueDecodingContainer {
    
    let codingPath: [CodingKey]
    
    let data: FirebirdData
    
    init(data: FirebirdData, codingPath: [CodingKey]) {
        self.data = data
        self.codingPath = codingPath
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
        fatalError("not implemented")
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        fatalError("not implemented")
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        switch (self.data.type) {
        case .int16:
            return Int(try self.decode(Int16.self))
        case .long:
            if (self.data.value?.count == Int32.bitWidth) {
                return Int(try self.decode(Int32.self))
            } else {
                return Int(try self.decode(Int64.self))
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
        fatalError("not implemented")
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        fatalError("not implemented")
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
        if let type = type as? Int.Type {
            return try self.decode(type) as! T
        }
        
        if let type = type as? String.Type {
            return try self.decode(type) as! T
        }
        
        fatalError("not implemented")
    }
    
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

