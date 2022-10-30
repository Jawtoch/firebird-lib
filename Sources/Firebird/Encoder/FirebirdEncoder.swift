public protocol FirebirdEncoder {
    
    func encode<T>(_ value: T, into data: FirebirdData) throws -> FirebirdData where T : Encodable
    
}
