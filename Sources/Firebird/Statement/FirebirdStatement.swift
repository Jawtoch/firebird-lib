//
//  FirebirdStatement.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

public class FirebirdStatement {
	
	/// The statement logger
	public let logger: Logger
	
	/// The statement handle
	var handle: isc_stmt_handle
	
	/// The statement query string
	public let query: String
	
	public let dialect: UInt16
	
	/// If the statement is allocated
	public var isAllocated: Bool {
		self.handle > 0
	}
	
	public var cursors: [Cursor]
	
	public let pool: FirebirdStoragePool
	
	/// Method used to free a statement
	public struct ClosingOption: RawRepresentable, Equatable {
		
		/// Properly close the cursor after fetching and processing all the rows resulting from the execution of a query
		public static let close = ClosingOption(DSQL_close)
		
		/// Drop the statement and all cursor associated with it
		public static let drop = ClosingOption(DSQL_drop)
		
		public static let unprepare = ClosingOption(DSQL_unprepare)
		
		public init?(rawValue: Int32) {
			self.rawValue = rawValue
		}
		
		public init(_ rawValue: Int32) {
			self.rawValue = rawValue
		}
		
		public var rawValue: Int32
		
		public typealias RawValue = Int32
	}
	
	public struct Cursor: CustomStringConvertible {
		
		public let name: String
		
		public var description: String {
			"Cursor(->\(self.name)<-)"
		}
		
		public init(name: String) {
			self.name = name
		}
		
	}
	
	/// Create a new statement with given query string
	/// - Parameters:
	///   - query: a query string
	///   - logger: a logger
	///   - handle: a previous statement handle, or `0` if not
	public init(_ query: String, dialect: UInt16 = FirebirdConstants.dialect, logger: Logger, handle: isc_stmt_handle = 0) {
		self.query = query
		self.dialect = dialect
		self.logger = logger
		self.handle = handle
		self.cursors = []
		self.pool = FirebirdStoragePool(self.logger)
	}
	
	/// Allocate a statement for subsequent use on the database.
	/// After uses, the statement must be deallocated via `free(_:)`
	/// - Parameters:
	///   - connection: an opened connection to the database
	/// - Throws: if an error occur during the allocation of the statement
	public func allocate(on connection: FirebirdConnection) throws {
		guard !self.isAllocated else {
			self.logger.warning("Statement \(self) is already allocated")
			return
		}
		
		var status = FirebirdError.statusArray
		
		if isc_dsql_allocate_statement(&status, &connection.handle, &self.handle) > 0 {
			throw FirebirdError(from: status)
		}
		
		self.logger.trace("Statement \(self) allocated on connection \(connection)")
	}
	
	/// Allocate a statement for subsequent use on the database.
	/// The statement is automatically deallocated when the connection to the database is closed.
	/// - Parameters:
	///   - connection: an opened connection to the database
	/// - Throws: if an error occur during the allocation of the statement
	public func allocateWithAutoRelease(on connection: FirebirdConnection) throws {
		guard !self.isAllocated else {
			self.logger.warning("Statement \(self) is already allocated")
			return
		}
		
		var status = FirebirdError.statusArray
		
		if isc_dsql_alloc_statement2(&status, &connection.handle, &self.handle) > 0 {
			throw FirebirdError(from: status)
		}
		
		self.logger.trace("Statement \(self) allocated on connection \(connection)")
	}
	
	/// Deallocate the statement on the database connection
	/// - Parameter option: method used to deallocate the statement
	/// - Throws: if an error occur while deallocating the statement
	public func free(_ option: ClosingOption = .close) throws {
		guard self.isAllocated else {
			self.logger.warning("Statement \(self) is not allocated")
			return
		}
		
		switch option {
			case .close:
				self.logger.trace("Closing \(self.cursors.count) cursor(s) on statement \(self)")
			case .drop:
				self.logger.trace("Dropping statement \(self)")
				if !self.cursors.isEmpty {
					self.logger.warning("Dropping statement \(self) with opened cursor(s), please call `free(.close)` before")
				}
			default:
				self.logger.trace("Closing \(self.cursors.count) with method \(option)")
		}
		
		self.pool.release()
		
		var status = FirebirdError.statusArray
		
		if isc_dsql_free_statement(&status, &self.handle, UInt16(option.rawValue)) > 0 {
			throw FirebirdError(from: status)
		}
		
		self.cursors.removeAll()
		
		self.logger.trace("Statement \(self) free, \(option)")
	}
	
	/// Create an empty descriptor area, used to bind or retrieve data from the statement execution
	/// - Parameters:
	///   - count: number of descriptor variables in the area
	///   - version: version of the area
	/// - Returns: an empty descriptor area of given size
	public func makeDescriptorArea(_ count: Int16, version: Int16 = FirebirdConstants.descriptorAreaVersion) -> FirebirdDescriptorArea {
		let pointer = UnsafeMutableRawPointer
			.allocate(byteCount: FirebirdDescriptorArea.XSQLDA_LENGTH(Int(count)), alignment: 1)
			.assumingMemoryBound(to: XSQLDA.self)
		let area = FirebirdDescriptorArea(from: pointer)
		area.version = version
		area.count = count
		
		return area
	}
	
	/// Describe the inputs of the statement, and allocate space on the descriptor area to store binded value
	/// - Parameter count: number of inputs in the statement
	/// - Throws: if an error occur while describing the inputs of the statement
	/// - Returns: a descriptor area with allocated descriptor variables
	public func describeInput(_ count: Int16 = 10) throws -> FirebirdDescriptorArea {
		let area = self.makeDescriptorArea(count)
		var status = FirebirdError.statusArray
		
		if isc_dsql_describe_bind(&status, &self.handle, UInt16(area.version), area.handle) > 0 {
			throw FirebirdError(from: status)
		}
		self.logger.trace("Describing input of statement \(self), in an area of size \(area.count)")
		
		if area.requiredCount > area.count {
			return try self.describeInput(area.requiredCount)
		}
		
		for variable in area.variables {
			self.pool.allocate(variable)
		}
		
		return area
	}
	
	/// Describe the output of the statement, and allocate space on the descriptor area for the database to put data on it
	/// - Parameter count: number of output per rows in the statement
	/// - Throws: if an error occur while describing the output of the statement
	/// - Returns: a descriptor area with allocated descriptor variables
	public func describeOutput(_ count: Int16 = 10) throws -> FirebirdDescriptorArea {
		let area = self.makeDescriptorArea(count)
		var status = FirebirdError.statusArray
		
		if isc_dsql_describe(&status, &self.handle, UInt16(area.version), area.handle) > 0 {
			throw FirebirdError(from: status)
		}
		self.logger.trace("Describing output of statement \(self), in an area of size \(area.count)")
		
		if area.requiredCount > area.count {
			return try self.describeOutput(area.requiredCount)
		}
		
		for variable in area.variables {
			self.pool.allocate(variable)
		}
		
		return area
	}
	
	/// Open a cursor on the statement
	/// - Parameter name: name of the cursor
	/// - Throws: if the cursor already exist
	/// - Returns: a cursor on the statement
	public func openCursor(name: String = String.randomString(length: 10)) throws -> Cursor {
		
		guard self.isAllocated else {
			self.logger.error("Unable to open cursor on non allocated statement \(self)")
			throw FirebirdCustomError("Unable to open cursor on non allocated statement \(self)")
		}
		
		guard !self.cursors.contains(where: { $0.name == name }) else {
			throw FirebirdCustomError("The statement \(self) already have a cursor named \(name)")
		}
		
		var status = FirebirdError.statusArray
		
		if isc_dsql_set_cursor_name(&status, &self.handle, name, .zero) > 0 {
			throw FirebirdError(from: status)
		}
		
		let cursor = Cursor(name: name)
		self.cursors.append(cursor)
		return cursor
	}
}

extension FirebirdStatement: CustomStringConvertible {
	
	public var description: String {
		let maxIndex = self.query.index(self.query.startIndex, offsetBy: min(20, self.query.count))
		var description = String(self.query.prefix(upTo: maxIndex))
		
		if maxIndex < self.query.endIndex {
			description += "…"
		}
		
		if !self.cursors.isEmpty {
			description += "(\(self.cursors.count) cursor(s) [\(self.cursors.map { $0.name }.joined(separator: ", "))]"
		}
		
		return description
	}
}
