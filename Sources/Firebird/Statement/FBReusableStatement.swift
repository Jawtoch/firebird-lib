import CFirebird
import Foundation
import Logging

public class FBReusableStatement {
	
	/// Cursor used for select-list query.
	public struct Cursor: CustomStringConvertible {
		
		/// Cursor name.
		public let name: String
		
		/// The statement that this cursor runs on.
		public let statement: FBReusableStatement
		
		/// Bindings collection to use to store row data.
		public let output: FirebirdBindings
		
		/// Current row index.
		private var rowIndex: Int
		
		/// Indicate if the cursor is a the end of the select-list.
		/// If `true`, no more rows can be fetched by this cursor.
		private var atEnd: Bool
		
		public var description: String {
			"Cursor(\(self.name))[index: \(self.rowIndex)]"
		}
		
		/// Open a cursor on a given executed statement
		/// - Parameters:
		///   - name: cursor name.
		///   - statement: the statement on which the cursor will run on
		///   - output: bindings collection to store row data
		public init(name: String, statement: FBReusableStatement, output: FirebirdBindings) {
			self.name = name
			self.statement = statement
			self.output = output
			self.rowIndex = 0
			self.atEnd = false
		}
		
		
		/// Try to fetch  the next row.
		/// - Returns: the next row if present, nil otherwise.
		/// - Throws: if the statement state is not `cursorOpen`, or if the fetch function call returns an error
		public mutating func fetch() throws -> FirebirdRow? {
			guard self.statement.stateIs(.cursorOpen) else {
				fatalError()
			}
			
			guard !self.atEnd else {
				return nil
			}
			
			defer {
				self.rowIndex += 1
			}
			
			var fields: [FirebirdField] = []
			
			try withStatus { status in
				if isc_dsql_fetch(&status, &self.statement.handle, 1, self.output.handle) == 0 {
					for bind in self.output.binds {
						let metadata = FirebirdData.Metadata(
							type: bind.type,
							subType: bind.subType,
							scale: bind.scale,
							length: bind.length)
						let data = FirebirdData(
							metadata: metadata,
							value: try bind.getData())
						let field = FirebirdField(
							name: bind.name,
							originalName: bind.originalName,
							tableOwner: bind.tableOwner,
							tableName: bind.tableName,
							data: data)
						fields.append(field)
					}
				} else {
					self.atEnd = true
				}
			}
			
			return fields.isEmpty ? nil : FirebirdRow(index: self.rowIndex, fields: fields)
		}
		
		/// Try to fetch all the rows from the current cursor position to the end of the select-list.
		/// - Returns: all the remainings rows.
		/// - Throws: if the statement state is not `cursorOpen`, or if the fetch function call returns an error
		public mutating func fetchAll() throws -> [FirebirdRow] {
			guard self.statement.stateIs(.cursorOpen) else {
				fatalError()
			}
			
			var rows: [FirebirdRow] = []
			
			while !self.atEnd {
				if let row = try self.fetch() {
					rows.append(row)
				}
			}
			
			return rows
		}
		
		/// Close the current cursor
		/// - Throws: if the statement state is not `cursorOpen`, or if an error occured while closing the cursor.
		public func close() throws {
			guard self.statement.stateIs(.cursorOpen) else {
				fatalError()
			}
			
			// Note: does the cursor close itself, or the statement close all opened cursor ?
			// Call to `statement.free(.close)` will close all opened cursors
			try self.statement.free(.close)
			
			self.statement.switchState(to: .executed)
			// End note
		}
		
	}
	
	/// Statement dialect version
	public struct Dialect: RawRepresentable, Equatable, CustomStringConvertible {
		
		public typealias RawValue = UInt16
		
		/// V5 & V6 compatible
		public static var version5 = Self(value: SQL_DIALECT_V5)!
		
		/// Diagnostic version
		public static var fiveToSix = Self(value: SQL_DIALECT_V6)!
		
		/// V6 only, support TIMESTAMP
		public static var version6 = Self(value: SQL_DIALECT_V6)!
		
		/// Current version defined in the Firebird C library
		public static var current = Self(value: SQL_DIALECT_CURRENT)!
		
		public var rawValue: RawValue
		
		public init?(value: Int32) {
			guard let rawValue = RawValue(exactly: value) else {
				return nil
			}
			
			self.init(rawValue: rawValue)
		}
		
		public init(rawValue: RawValue) {
			self.rawValue = rawValue
		}
		
		public var description: String {
			switch self {
				case .version5:
					return "version5"
				case .fiveToSix:
					return "5to6"
				case .version6:
					return "version6"
				case .current:
					return "current"
				default:
					return "\(self.rawValue)"
			}
		}
		
	}
	
	public struct FreeOption: RawRepresentable, Equatable, CustomStringConvertible {
		
		/// Properly close the cursor after fetching and processing all the rows resulting from the execution of a query.
		/// This closes a cursor, but the statement it was associated with remains available for further execution.
		public static let close = FreeOption(DSQL_close)
		
		/// Drop the statement and all cursor associated with it.
		/// This option frees all resources associated with the statement handle, and closes any open cursors associated with the statement handle.
		public static let drop = FreeOption(DSQL_drop)
		
		/// This option allows for the asynchronous cancellation of an executing statement.
		/// Once a statement has been unprepared, any subsequent execution restarts the statement, rather than resuming it.
		public static let unprepare = FreeOption(DSQL_unprepare)
		
		public typealias RawValue = UInt16
		
		public let rawValue: UInt16
		
		public init?(rawValue: RawValue) {
			self.rawValue = rawValue
		}
		
		private init(_ int32: Int32) {
			self.rawValue = Self.RawValue(int32)
		}
		
		public var description: String {
			switch self {
				case .close:
					return "close"
				case .drop:
					return "drop"
				case .unprepare:
					return "unprepare"
				default:
					return "\(self.rawValue)"
			}
		}
		
	}
	
	/// Statement state, used to ensure that all steps are performed in the right order
	public enum State {
		
		/// New statement, non allocated
		case new
		
		/// Statement allocated on a database
		case allocated
		
		/// Prepared statement
		case prepared
		
		/// Executed statement
		case executed
		
		/// Statemement has an opened cursor
		case cursorOpen
	}
	
	/// Statement logger
	public let logger: Logger
	
	/// Statement query string
	public let query: String
	
	/// Statement dialect
	public let dialect: Dialect
	
	/// Statement state
	public private(set) var state: State
	
	/// Handle used to manage the statement with the Firebird C library.
	/// This handle should only be changed by the Firebird C library.
	/// Setting this value manualy can lead to unpredictable behaviours.
	internal var handle: isc_stmt_handle
	
	/// Indicate if the statement is allocated.
	public var isAllocated: Bool {
		self.handle > 0
	}
	
	/// Create a new reusable statement
	/// - Parameters:
	///   - handle: statement handle, default to 0
	///   - query: statement query string
	///   - dialect: statement dialect, must be less than or equal to the dialect of the client, default to `current`
	///   - logger: statement logger
	public init(handle: isc_stmt_handle = 0, query: String, dialect: Dialect = .current, logger: Logger) {
		self.handle = handle
		self.query = query
		self.dialect = dialect
		self.logger = logger
		self.state = .new
	}
	
	/// Force the state of this statement. Use this method at your own risk.
	/// - Parameter newState: the new statement state
	public func forceState(_ state: State) {
		self.logger.warning("Forcing \(self) state from \(self.state) to state \(state)")
		self.state = state
	}
	
	/// Switch the state of this statement.
	/// - Parameter newState: the new statement state.
	private func switchState(to newState: State) {
		self.logger.debug("Switching \(self) state from \(self.state) to \(newState)")
		self.state = newState
	}
	
	/// Return a boolean value indicating if the statement state is contained in a list of states.
	/// - Parameter states: a list of states
	/// - Returns: `true` if the statement state is in the list of state, `false` otherwise.
	public func stateIs(_ states: State...) -> Bool {
		states.contains(self.state)
	}
	
	/// Allocate the statement on a connection.
	/// - Parameter connection: a connection.
	/// - Throws: if an error occured while allocating the statement.
	public func allocate(on connection: FBConnection) throws {
		self.logger.debug("Allocating \(self) on \(connection)")
		guard self.stateIs(.new) else {
			fatalError()
		}
		
		guard !self.isAllocated else {
			fatalError()
		}
		
		guard !connection.isClosed else {
			fatalError()
		}
		
		try withStatus { status in
			isc_dsql_alloc_statement2(&status, &connection.handle, &self.handle)
		}
		
		self.logger.debug("\(self) allocated on \(connection)")
		
		self.switchState(to: .allocated)
	}
	
	/// Prepare the statement on a transaction.
	/// - Parameter transaction: a transaction.
	/// - Throws: if an error occured while preparing the statement.
	public func prepare(on transaction: FBTransaction) throws {
		self.logger.debug("Preparing \(self) on \(transaction)")
		guard self.stateIs(.allocated) else {
			fatalError()
		}
		
		guard self.isAllocated else {
			fatalError()
		}
		
		guard !transaction.isClosed else {
			fatalError()
		}
		
		try withStatus { status in
			isc_dsql_prepare(&status, &transaction.handle, &self.handle, 0, self.query, self.dialect.rawValue, nil)
		}
		
		self.logger.debug("\(self) prepared on \(transaction)")
		
		self.switchState(to: .prepared)
	}
	
	/// Close the statement and all the resources 
	func close() throws {
		self.logger.debug("Closing \(self)")
		try self.free(.drop)
		
		self.logger.debug("\(self) closed")
		
		self.switchState(to: .new)
	}
	
	/// Unprepare the statement
	/// - Throws: if an error occured while unpreparing the statement
	func unprepare() throws {
		self.logger.debug("Unpreparing \(self)")
		guard self.stateIs(.prepared) else {
			fatalError()
		}
		
		try self.free(.unprepare)
		
		self.logger.debug("\(self) unprepared")
		
		self.switchState(to: .allocated)
	}
	
	/// Free the statement with given option.
	/// - Parameter option: free option.
	/// - Throws: if an error occured while freeing the statement
	public func free(_ option: FreeOption) throws {
		self.logger.debug("Freeing \(self) with option \(option)")
		try withStatus { status in
			isc_dsql_free_statement(&status, &self.handle, option.rawValue)
		}
	}
	
	/// Get bindings collection with statement input description
	/// - Parameter size: initial collection size. If the size is not large enougth, a new bindings collection will be created with enougth size.
	/// - Returns: bindings collection allocated for the bindings of the statement. Each binding for the collection must be configured with allocated storage for nil and / or data.
	public func describeInput(size: Int16 = 10) throws -> FirebirdBindings {
		let rowDescriptor = FirebirdBindings(numberOfFields: size, version: .current)
		
		try withStatus { status in
			isc_dsql_describe_bind(&status, &self.handle, 1, rowDescriptor.handle)
		}
		
		if rowDescriptor.numberOfFields > rowDescriptor.numberOfAllocatedFields {
			let n = rowDescriptor.numberOfFields
			return try self.describeInput(size: n)
		}
		
		return rowDescriptor
	}
	
	/// Get bindings collection with statement output description
	/// - Parameter size: initial collection size. If the size is not large enougth, a new bindings collection will be created with enougth size.
	/// - Returns: bindings collection allocated for the bindings of the statement. Each binding for the collection must be configured with allocated storage for nil and / or data.
	public func describeOutput(size: Int16 = 10) throws -> FirebirdBindings {
		let rowDescriptor = FirebirdBindings(numberOfFields: size, version: .current)
		
		try withStatus { status in
			isc_dsql_describe(&status, &self.handle, 1, rowDescriptor.handle)
		}
		
		if rowDescriptor.numberOfFields > rowDescriptor.numberOfAllocatedFields {
			let n = rowDescriptor.numberOfFields
			return try self.describeOutput(size: n)
		}
		
		return rowDescriptor
	}
	
	/// Execute the statement
	/// - Parameters:
	///   - transaction: the opened transaction to run on
	///   - input: input bindings collection to use for statement parameters
	/// - Throws: if the statement state is not `prepared`, if the transaction is not opened, or if an error occured while executing the statement.
	public func execute(on transaction: FBTransaction, input: FirebirdBindings? = nil) throws {
		self.logger.debug("Executing \(self) on \(transaction)")
		guard self.stateIs(.prepared) else {
			fatalError()
		}
		
		guard !transaction.isClosed else {
			fatalError()
		}
		
		try withStatus { status in
			isc_dsql_execute(&status, &transaction.handle, &self.handle, 1, input?.handle)
		}
		
		self.logger.debug("\(self) executed on \(transaction)")
		self.switchState(to: .executed)
	}
	
	/// Open a cursor on the statement.
	/// - Parameters:
	///   - name: cursor name, must be unique.
	///   - output: bindings collection to store row data on fetch.
	/// - Returns: an openend cursor on this statement.
	/// - Throws: if the statement state is not `executed`, or if an error occured while opening the cursor.
	public func openCursor(_ name: String, output: FirebirdBindings) throws -> Cursor {
		self.logger.debug("Opening cursor \(name) on \(self)")
		guard self.stateIs(.executed) else {
			fatalError()
		}
		
		try withStatus { status in
			isc_dsql_set_cursor_name(&status, &self.handle, name, 0)
		}
		
		self.switchState(to: .cursorOpen)
		
		let cursor = Cursor(name: name, statement: self, output: output)
		
		self.logger.debug("\(cursor) opened on \(self)")
		
		return cursor
	}
	
}

extension FBReusableStatement: CustomStringConvertible {
	
	public var description: String {
		"FBStatement(\(self.handle))"
	}
}

