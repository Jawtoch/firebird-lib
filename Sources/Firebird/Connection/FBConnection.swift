import CFirebird
import Logging

public class FBConnection: FirebirdConnection {
    
    public enum Error: FirebirdError {
        case invalidParametersCount(count: Int)
    }
    
    public let logger: Logger

    public var handle: isc_db_handle
    
    internal var transaction: FBTransaction?
    
    public var isClosed: Bool {
        self.handle == 0
    }
    
    public init(handle: isc_db_handle = 0, logger: Logger) {
        self.handle = handle
        self.logger = logger
        self.transaction = nil
    }
    
    public func attach(_ url: String, parameters: [ISC_SCHAR] = []) throws {
        let _ = try parameters.withUnsafeBufferPointer { unsafeParameters in
            guard let parametersCount = Int16(exactly: parameters.count) else {
                throw Error.invalidParametersCount(count: parameters.count)
            }
            
            try withStatusThrowing { status in
                isc_attach_database(&status, 0, url, &self.handle, parametersCount, unsafeParameters.baseAddress)
            }
        }
    }
    
    public func detach() throws {
        try withStatusThrowing { status in
            isc_detach_database(&status, &self.handle)
        }
    }
    
}
