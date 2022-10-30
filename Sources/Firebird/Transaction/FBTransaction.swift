import CFirebird
import Logging

public class FBTransaction: FirebirdTransaction {
    
    public enum Error: FirebirdError {
        case invalidMessageSize(message: String)
    }
    
    public let logger: Logger
    
    public var handle: isc_tr_handle
    
    public var isClosed: Bool {
        self.handle == 0
    }
    
    public init(handle: isc_tr_handle = 0, logger: Logger) {
        self.handle = handle
        self.logger = logger
    }
    
    public func start(on connection: FBConnection) throws {
        /// https://docwiki.embarcadero.com/InterBase/2020/en/Calling_isc_start_multiple()
        struct TEB {
            
            let database: UnsafePointer<isc_db_handle>
            
            let count: CLong
            
            let parameters: UnsafeBufferPointer<CChar>?
            
        }
        
        try withUnsafePointer(to: &connection.handle) { unsafeConnectionHandle in
            let block = TEB(database: unsafeConnectionHandle, count: 0, parameters: nil)
            var blocks = [ block ]
            try withStatusThrowing { status in
                isc_start_multiple(&status, &self.handle, Int16(blocks.count), &blocks)
            }
        }
    }
    
    public func reconnect(transactionId: Int32, on connection: FBConnection) throws {
        try withUnsafeBytes(of: transactionId) { unsafeTransactionId in
            let basePointer = unsafeTransactionId.baseAddress?.assumingMemoryBound(to: ISC_SCHAR.self)
            try withStatusThrowing { status in
                isc_reconnect_transaction(&status, &connection.handle, &self.handle, Int16(unsafeTransactionId.count), basePointer)
            }
        }
    }
    
    public func prepare() throws {
        let (status, _ ) = withStatus { status in
            isc_prepare_transaction(&status, &self.handle)
        }
        
        if statusContainsError(status) {
            try self.rollback()
            throw FirebirdNativeError(status: status)
        }
    }
    
    public func prepare(transactionMessage message: String) throws {
        guard let messageSize = ISC_USHORT(exactly: message.count) else {
            throw Error.invalidMessageSize(message: message)
        }
        
        let (status, _ ) = withStatus { status in
            isc_prepare_transaction2(&status, &self.handle, messageSize, message)
        }
        
        if statusContainsError(status) {
            try self.rollback()
            throw FirebirdNativeError(status: status)
        }
    }
    
    public func commit() throws {
        try withStatusThrowing { status in
            isc_commit_transaction(&status, &self.handle)
        }
    }
    
    public func commitRetaining() throws {
        try withStatusThrowing { status in
            isc_commit_retaining(&status, &self.handle)
        }
    }
    
    public func rollback() throws {
        try withStatusThrowing { status in
            isc_rollback_transaction(&status, &self.handle)
        }
    }
    
    public func rollbackRetaining() throws {
        try withStatusThrowing { status in
            isc_rollback_retaining(&status, &self.handle)
        }
    }
}

