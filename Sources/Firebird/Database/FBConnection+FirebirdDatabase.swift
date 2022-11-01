import CFirebird

extension FBConnection: FirebirdDatabase {
        
    public var inTransaction: Bool {
        self.transaction != nil
    }
    
    public func drop() throws {
        try withStatusThrowing { status in
            isc_drop_database(&status, &self.handle)
        }
    }
    
    @discardableResult
    public func withTransaction<T>(_ closure: (FirebirdTransaction) throws -> T) throws -> T {
        if let transaction = self.transaction {
            return try closure(transaction)
        }
        
        let transaction = FBTransaction(logger: self.logger)
        do {
            try transaction.start(on: self)
            let result = try closure(transaction)
            try transaction.commit()
            return result
        } catch let error {
            try transaction.rollback()
            throw error
        }
    }
    
    public func query(_ string: String, _ binds: [Encodable] = [], onRow: (FirebirdRow) throws -> Void) throws {
        let statement = FBStatement(logger: self.logger)
        
        do {
            try statement.allocate(on: self)
            
            try self.withTransaction { transaction in
                
                let transaction = transaction as! FBTransaction
                
                try statement.prepare(string, on: transaction)
                
                var inputDescriptorArea: FirebirdXSQLDescriptorArea? = nil
                if !binds.isEmpty {
                    inputDescriptorArea = try statement.describeBind(capacity: Int16(binds.count))
                }
                
                let outputDescriptorArea = try statement.describe(capacity: 10)
                
                let allocator = FirebirdXSQLVariableAllocator()
                
                if let inputDescriptorArea {
                    for variable in inputDescriptorArea {
                        allocator.allocate(variable)
                    }
                    
                    let encoder = FBEncoder()
                    
                    let variablesDatas = try inputDescriptorArea.map { try $0.readData() }
                    let datas = try zip(binds, variablesDatas).map { (bind: Encodable, data: FirebirdData) in
                        try encoder.encode(bind, into: data)
                    }
                    
                    try inputDescriptorArea.write(datas)
                }
                
                for variable in outputDescriptorArea {
                    allocator.allocate(variable)
                }
                
                try statement.execute(on: transaction, inputDescriptorArea: inputDescriptorArea)
                
                let cursorName = String.random(of: 16)
                try statement.openCursor(named: cursorName)
                
                let decoder = FBDecoder()
                
                var index = 0
                while case let fetchStatus = try statement.fetch(into: outputDescriptorArea), fetchStatus == .ok {
                    let variablesDatas = try outputDescriptorArea.map { try $0.readData() }
                    let row = FirebirdRow(decoder: decoder, index: index, datas: variablesDatas)
                    try onRow(row)
                    index += 1
                }
                
                allocator.release()
            }
            
            try statement.free(.drop)
        } catch let error {
            try statement.free(.drop)
            throw error
        }
    }

}

private extension String {
    
    static func random(of n: Int) -> String {
          let digits = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
          return String(Array(0 ..< n).map { _ in digits.randomElement()! })
       }
    
}
