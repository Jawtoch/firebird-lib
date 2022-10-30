import Foundation

public class FBEncoder: FirebirdEncoder {
    
    public init() { }
    
    public func encode<T>(_ value: T, into data: FirebirdData) throws -> FirebirdData where T : Encodable {
        let encoder = FBEncoderImpl(data: data, codingPath: [])
        try value.encode(to: encoder)
                
        return FirebirdData(
            name: data.name,
            type: data.type,
            subType: data.subType,
            value: encoder.encoded)
    }
    
}

class FBEncoderImpl: Encoder {
    
    let codingPath: [CodingKey]
    
    let userInfo: [CodingUserInfoKey : Any] = [:]
    
    let data: FirebirdData
    
    var encoded: Data?
    
    init(data: FirebirdData, codingPath: [CodingKey]) {
        self.data = data
        self.codingPath = codingPath
        self.encoded = nil
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        fatalError("not implemented")
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("not implemented")
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        FBEncoderSingleValueEncodingContainer(encoder: self, codingPath: self.codingPath)
    }
    
}

internal class FBEncoderSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    let codingPath: [CodingKey]
    
    let encoder: FBEncoderImpl
    
    var data: FirebirdData {
        self.encoder.data
    }
    
    var encoded: Data? {
        get {
            self.encoder.encoded
        }
        set {
            self.encoder.encoded = newValue
        }
    }
    
    init(encoder: FBEncoderImpl, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }
    
    func encodeNil() throws {
        self.encoded = nil
    }
    
    func encode(_ value: Bool) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: String) throws {
        switch (self.data.type) {
        case .varying:
            self.encoded = try _encodeStringAsVarying(value: value)
            break
        case .text:
            self.encoded = try _encodeStringAsText(value: value)
            break
        default:
            fatalError("not implemented")
        }
    }
    
    func encode(_ value: Double) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: Float) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: Int) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: Int8) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: Int16) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: Int32) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: Int64) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: UInt) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: UInt8) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: UInt16) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: UInt32) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: UInt64) throws {
        fatalError("not implemented")
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        fatalError("not implemented")
    }

}

fileprivate func _encodeStringAsText(value: String) throws -> Data {
    guard let data = value.data(using: .utf8) else {
        fatalError("not implemented")
    }
    
    return data
}


fileprivate func _encodeStringAsVarying(value: String) throws -> Data {
    guard let data = value.data(using: .utf8) else {
        fatalError("not implemented")
    }
    
    let size = Int16(data.count)
    
    let sizeBytes = withUnsafeBytes(of: size) { unsafeSize in
        Data(unsafeSize)
    }
    
    return sizeBytes + data
}
