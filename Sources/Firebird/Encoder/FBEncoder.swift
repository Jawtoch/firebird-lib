import CFirebird
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
            length: data.length,
            scale: data.length,
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
        let scale = fabs(Double(self.data.scale))
        let multiplier = pow(10.0, scale)
        let scaledValue = value * multiplier
        
        let intValue = Int32(scaledValue.rounded())
        
        let bytes = withUnsafeBytes(of: intValue) { Data($0) }
        
        self.encoded = bytes
    }
    
    func encode(_ value: Float) throws {
        fatalError("not implemented")
    }
    
    func encode(_ value: Int) throws {
        switch (self.data.type) {
        case .int16:
            try self.encode(Int16(value))
        case .long:
            let bits = Int(self.data.length * 8)
            
            switch bits {
            case Int32.bitWidth:
                try self.encode(Int32(value))
            case Int64.bitWidth:
                try self.encode(Int64(value))
            default:
                fatalError("not implemented")
            }
        case .int64:
            try self.encode(Int64(value))
        default:
            fatalError("not implemented")
        }
    }
    
    func encode(_ value: Int8) throws {
        let bytes = withUnsafeBytes(of: value) { unsafeBytes in
            Data(unsafeBytes)
        }
        
        self.encoded = bytes
    }
    
    func encode(_ value: Int16) throws {
        let bytes = withUnsafeBytes(of: value) { unsafeBytes in
            Data(unsafeBytes)
        }
        
        self.encoded = bytes
    }
    
    func encode(_ value: Int32) throws {
        let bytes = withUnsafeBytes(of: value) { unsafeBytes in
            Data(unsafeBytes)
        }
        
        self.encoded = bytes
    }
    
    func encode(_ value: Int64) throws {
        let bytes = withUnsafeBytes(of: value) { unsafeBytes in
            Data(unsafeBytes)
        }
        
        self.encoded = bytes
    }
    
    func encode(_ value: Date) throws {
        let timeInterval = value.timeIntervalSince1970.rounded()
        var rawTime: time_t = time_t(timeInterval)
        var timeInfo = gmtime(&rawTime)
        var timestamp: ISC_TIMESTAMP!
        isc_encode_timestamp(&timeInfo, &timestamp)
        
        let bytes = withUnsafeBytes(of: &timestamp) {
            Data($0)
        }
        
        self.encoded = bytes
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
