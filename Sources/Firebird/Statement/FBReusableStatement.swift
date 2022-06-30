//
//  FBReusableStatement.swift
//
//
//  Created by Ugo Cottin on 28/06/2022.
//

import CFirebird
import Foundation
import Logging

public class FBReusableStatement {
	
	public struct Cursor: CustomStringConvertible {
		
		public let name: String
		
		public let statement: FBReusableStatement
		
		public let output: FirebirdBindings
		
		private var rowIndex: Int
		
		private var atEnd: Bool
		
		public var description: String {
			"Cursor(\(self.name))[index: \(self.rowIndex)]"
		}
		
		public init(name: String, statement: FBReusableStatement, output: FirebirdBindings) {
			self.name = name
			self.statement = statement
			self.output = output
			self.rowIndex = 0
			self.atEnd = false
		}
		
		public mutating func fetch() throws -> FirebirdRow? {
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
		
		public func close() throws {
			guard self.statement.stateIs(.cursorOpen) else {
				fatalError()
			}
			
			try self.statement.free(.close)
			
			self.statement.switchState(to: .prepared)
		}
		
	}
	
	public struct Dialect: RawRepresentable, Equatable, CustomStringConvertible {
		
		public typealias RawValue = UInt16
		
		public static var version5 = Self(value: SQL_DIALECT_V5)!
		
		public static var fiveToSix = Self(value: SQL_DIALECT_V6)!
		
		public static var version6 = Self(value: SQL_DIALECT_V6)!
		
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
		
		/// Properly close the cursor after fetching and processing all the rows resulting from the execution of a query
		public static let close = FreeOption(DSQL_close)
		
		/// Drop the statement and all cursor associated with it
		public static let drop = FreeOption(DSQL_drop)
		
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
	
	public enum State {
		case new
		case allocated
		case prepared
		case executed
		case cursorOpen
	}
	
	public let logger: Logger
	
	public let query: String
	
	public let dialect: Dialect
	
	public private(set) var state: State
	
	internal var handle: isc_stmt_handle
	
	public var isAllocated: Bool {
		self.handle > 0
	}
	
	public init(handle: isc_stmt_handle = 0, query: String, dialect: Dialect = .current, logger: Logger) {
		self.handle = handle
		self.query = query
		self.dialect = dialect
		self.logger = logger
		self.state = .new
	}
	
	public func forceState(_ state: State) {
		self.logger.warning("Forcing \(self) state from \(self.state) to state \(state)")
		self.state = state
	}
	
	private func switchState(to newState: State) {
		self.logger.debug("Switching \(self) state from \(self.state) to \(newState)")
		self.state = newState
	}
	
	public func stateIs(_ states: State...) -> Bool {
		states.contains(self.state)
	}
	
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
	
	func close() throws {
		self.logger.debug("Closing \(self)")
		try self.free(.drop)
		
		self.logger.debug("\(self) closed")
		
		self.switchState(to: .new)
	}
	
	func unprepare() throws {
		self.logger.debug("Unpreparing \(self)")
		guard self.stateIs(.prepared) else {
			fatalError()
		}
		
		try self.free(.unprepare)
		
		self.logger.debug("\(self) unprepared")
		
		self.switchState(to: .allocated)
	}
	
	public func free(_ option: FreeOption) throws {
		self.logger.debug("Freeing \(self) with option \(option)")
		try withStatus { status in
			isc_dsql_free_statement(&status, &self.handle, option.rawValue)
		}
	}
	
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
		
	public func execute(on transaction: FBTransaction, input: FirebirdBindings? = nil) throws {
		self.logger.debug("Executing \(self) on \(transaction)")
		guard self.stateIs(.prepared, .executed) else {
			fatalError()
		}
		
		try withStatus { status in
			isc_dsql_execute(&status, &transaction.handle, &self.handle, 1, input?.handle)
		}
		
		self.logger.debug("\(self) executed on \(transaction)")
		self.switchState(to: .executed)
	}
	
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

