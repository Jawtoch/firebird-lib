import CFirebird
import Logging

public protocol FirebirdStatement {
	
	var logger: Logger { get }
	
	var handle: isc_stmt_handle { get set }
	
	var isClosed: Bool { get }
	
}

public class FBStatement: FirebirdStatement {
	
    public enum Error: FirebirdError {
        case cursorNameTooLong(cursorName: String)
    }
    
	public enum FetchStatus: ISC_STATUS {
		case ok = 0
		case noMoreRows = 100
	}
    
	public let logger: Logger
	
	public var handle: isc_stmt_handle
	
	public var isClosed: Bool {
		self.handle == 0
	}
	
	public init(handle: isc_stmt_handle = 0, logger: Logger) {
		self.logger = logger
		self.handle = handle
	}
	
	public func allocate(on connection: FBConnection) throws {
		try withStatusThrowing { status in
			isc_dsql_allocate_statement(&status, &connection.handle, &self.handle)
		}
	}
	
	public func allocate2(on connection: FBConnection) throws {
		try withStatusThrowing { status in
			isc_dsql_alloc_statement2(&status, &connection.handle, &self.handle)
		}
	}
	
	public func describe(capacity: Int16) throws -> FirebirdXSQLDescriptorArea {
		let descriptorArea = FirebirdXSQLDescriptorArea(version: .version1, initialCapacity: capacity)
		try withStatusThrowing { status in
			isc_dsql_describe(&status, &self.handle, UInt16(descriptorArea.version.rawValue), descriptorArea.handle)
		}
		
		if descriptorArea.requiredCapacity > descriptorArea.capacity {
			let requiredCapacity = descriptorArea.requiredCapacity
			return try self.describe(capacity: requiredCapacity)
		}
		
		return descriptorArea
	}
	
	public func describeBind(capacity: Int16) throws -> FirebirdXSQLDescriptorArea {
		let descriptorArea = FirebirdXSQLDescriptorArea(version: .version1, initialCapacity: capacity)
		try withStatusThrowing { status in
			isc_dsql_describe_bind(&status, &self.handle, UInt16(descriptorArea.version.rawValue), descriptorArea.handle)
		}
		
		if descriptorArea.requiredCapacity > descriptorArea.capacity {
			let requiredCapacity = descriptorArea.requiredCapacity
			return try self.describeBind(capacity: requiredCapacity)
		}
		
		return descriptorArea
	}
	
	public func execute(on transaction: FBTransaction, inputDescriptorArea: FirebirdXSQLDescriptorArea? = nil) throws {
		try withStatusThrowing { status in
			isc_dsql_execute(&status, &transaction.handle, &self.handle, UInt16((inputDescriptorArea?.version ?? .version1).rawValue), inputDescriptorArea?.handle)
		}
	}
	
	public func execute2(on transaction: FBTransaction, inputDescriptorArea: FirebirdXSQLDescriptorArea? = nil, outputDescriptorArea: FirebirdXSQLDescriptorArea? = nil) throws {
		try withStatusThrowing { status in
			isc_dsql_execute2(&status, &transaction.handle, &self.handle, UInt16((inputDescriptorArea?.version ?? .version1).rawValue), inputDescriptorArea?.handle, outputDescriptorArea?.handle)
		}
	}
	
	public func fetch(into outputDescriptorArea:  FirebirdXSQLDescriptorArea? = nil) throws -> FetchStatus {
		let (status, result) = withStatus { status in
			isc_dsql_fetch(&status, &self.handle, UInt16((outputDescriptorArea?.version ?? .version1).rawValue), outputDescriptorArea?.handle)
		}
		
		guard let fetchStatus = FetchStatus(rawValue: result) else {
			throw FirebirdNativeError(status: status)
		}
		
		return fetchStatus
	}
	
	public struct FreeOption: RawRepresentable {
		
		public typealias RawValue = UInt16
		
		public static let close = Self(rawValue: Self.RawValue(DSQL_close))
		
		public static let drop = Self(rawValue: Self.RawValue(DSQL_drop))
		
		public static let unprepare = Self(rawValue: Self.RawValue(DSQL_unprepare))
		
		public let rawValue: RawValue
		
		public init(rawValue: RawValue) {
			self.rawValue = rawValue
		}
		
	}
	
	public func free(_ option: FreeOption) throws {
		try withStatusThrowing { status in
			isc_dsql_free_statement(&status, &self.handle, option.rawValue)
		}
	}
	
	public func prepare(_ query: String, on transaction: FBTransaction, outputDescriptorArea: FirebirdXSQLDescriptorArea? = nil) throws {
		try withStatusThrowing { status in
            isc_dsql_prepare(&status, &transaction.handle, &self.handle, 0, query, FirebirdSQLDialect.current.rawValue, outputDescriptorArea?.handle)
		}
	}
	
	public func openCursor(named cursorName: String) throws {
        guard let cursorNameSize = UInt16(exactly: cursorName.count) else {
            throw Error.cursorNameTooLong(cursorName: cursorName)
        }
        
		try withStatusThrowing { status in
			isc_dsql_set_cursor_name(&status, &self.handle, cursorName, cursorNameSize)
		}
	}
	
}
