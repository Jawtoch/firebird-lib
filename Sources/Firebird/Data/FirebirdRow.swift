public struct FirebirdRow {
    
    public enum Error: FirebirdError {
        case invalidColumn(column: String)
        case missingData(column: String)
    }
    
    public let decoder: FirebirdDecoder
    
    public let index: Int
    
    public var columns: [String] {
        self.datas.map { $0.name }
    }
    
    public let datas: [FirebirdData]
    
    private func prefix(_ value: String) -> String {
        String(value.prefix(31))
    }
    
    public func contains(column: String) -> Bool {
        self.columns.contains(self.prefix(column))
    }
    
    public func column(_ columnName: String) throws -> FirebirdData {
        let columnName = self.prefix(columnName)
        guard self.contains(column: columnName) else {
            throw Error.invalidColumn(column: columnName)
        }
        
        guard let data = self.datas.first(where: { $0.name == columnName }) else {
            throw Error.missingData(column: columnName)
        }
        
        return data
    }
    
    public func decode<T>(column: String, as type: T.Type) throws -> T where T : Decodable {
        let data = try self.column(column)
        
        let decoded = try self.decoder.decode(type, from: data)
        
        return decoded
    }
    
}
