import CFirebird
import Logging

public protocol FirebirdDatabase {
    
    var logger: Logger { get }
    
    var inTransaction: Bool { get }
    
    func drop() throws
    
    @discardableResult
    func withTransaction<T>(_ closure: (FirebirdTransaction) throws -> T) throws -> T
    
    func query(_ string: String, _ binds: [Encodable], onRow: (FirebirdRow) throws -> Void) throws
    
}

extension FirebirdDatabase {
    
    @discardableResult
    public func query(_ string: String, _ binds: [Encodable] = []) throws -> [FirebirdRow] {
        var rows: [FirebirdRow] = []
        try self.query(string, binds) { rows.append($0) }
        
        return rows
    }
    
}
