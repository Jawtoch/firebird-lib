public protocol FirebirdDecoder {
    
    func decode<T>(_ type: T.Type, from data: FirebirdData) throws -> T where T : Decodable
    
}
