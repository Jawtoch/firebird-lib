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
	
	/// If the statement is allocated
	public var isAllocated: Bool {
		self.handle > 0
	}
	
	/// Create a new statement with given query string
	/// - Parameters:
	///   - query: a query string
	///   - logger: a logger
	///   - handle: a previous statement handle, or `0` if not
	public init(_ query: String, logger: Logger, handle: isc_stmt_handle = 0) {
		self.handle = handle
		self.query = query
		self.logger = logger
	}
	
	/// Allocate a statement for subsequent use on the database.
	/// After uses, the statement must be deallocated via `free(_:)`
	/// - Parameters:
	///   - connection: an opened connection to the database
	/// - Throws: if an error occur during the allocation of the statement
	public func allocate(on connection: FirebirdConnection) throws {
		guard self.isAllocated else {
			self.logger.warning("Statement \(self) is already allocated")
			return
		}
		
		var status = FirebirdError.statusArray
		
		if isc_dsql_allocate_statement(&status, &connection.handle, &self.handle) > 0 {
			throw FirebirdError(from: status)
		}
		
		self.logger.info("Statement \(self) allocated on connection \(connection)")
	}
	
	/// Allocate a statement for subsequent use on the database.
	/// The statement is automatically deallocated when the connection to the database is closed.
	/// - Parameters:
	///   - connection: an opened connection to the database
	/// - Throws: if an error occur during the allocation of the statement
	public func allocateWithAutoRelease(on connection: FirebirdConnection) throws {
		guard self.isAllocated else {
			self.logger.warning("Statement \(self) is already allocated")
			return
		}
		
		var status = FirebirdError.statusArray
		
		if isc_dsql_alloc_statement2(&status, &connection.handle, &self.handle) > 0 {
			throw FirebirdError(from: status)
		}
		
		self.logger.info("Statement \(self) allocated on connection \(connection)")
	}
	
	public func free(_ option: ClosingOption = .close) throws {
		guard !self.isAllocated else {
			self.logger.warning("Statement \(self) is not allocated")
			return
		}
		
		var status = FirebirdError.statusArray
		
		if isc_dsql_free_statement(&status, &self.handle, UInt16(option.rawValue)) > 0 {
			throw FirebirdError(from: status)
		}
		
		self.logger.info("Statement \(self) free")
	}
	
	public struct ClosingOption: RawRepresentable {
		
		public static let close = ClosingOption(DSQL_close)
		
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
}

extension FirebirdStatement: CustomStringConvertible {
	
	public var description: String {
		let maxIndex = self.query.index(self.query.startIndex, offsetBy: max(20, self.query.count))
		var description = String(self.query.prefix(upTo: maxIndex))
		
		if maxIndex < self.query.endIndex {
			description += "…"
		}
		
		return description
	}
}
