import fbclient
import Foundation
import Logging

protocol NextFirebirdDatabase {
	
	var logger: Logger { get }
	
	// MARK: - Transaction
	var inTransaction: Bool { get }
	
	func startTransaction() throws -> NextFirebirdDatabaseInTransaction
	
	func commit() throws -> NextFirebirdDatabase
	
	func rollback() throws -> NextFirebirdDatabase
	
	// MARK: - Query
	func query(_ queryString: String, parameters: [Encodable]) throws -> NextFirebirdQuery
	
}

class NextFirebirdConnection {
	
	let handle: isc_db_handle
	
	let logger: Logger
	
	init(handle: isc_db_handle, logger: Logger) {
		self.handle = handle
		self.logger = logger
	}
	
	/*static func connect() -> NextFirebirdDatabase {
		
	}*/
	
}

extension NextFirebirdConnection: NextFirebirdDatabase {

	var inTransaction: Bool {
		false
	}
	
	func startTransaction() throws -> NextFirebirdDatabaseInTransaction {
		let transactionHandle: isc_tr_handle = 0
		// api call
		let transaction = NextFirebirdTransaction(handle: transactionHandle)
		return NextFirebirdDatabaseInTransaction(database: self, transaction: transaction)
	}
	
	func commit() throws -> NextFirebirdDatabase {
		throw FirebirdCustomError(reason: "no transaction")
	}
	
	func rollback() throws -> NextFirebirdDatabase {
		throw FirebirdCustomError(reason: "no transaction")
	}
	
	func query(_ queryString: String, parameters: [Encodable]) throws -> NextFirebirdQuery {
		return NextFirebirdQuery(database: self, sql: queryString, binds: parameters)
	}

}

struct NextFirebirdDatabaseInTransaction {
	
	let database: NextFirebirdDatabase
	let transaction: NextFirebirdTransaction
	
}

extension NextFirebirdDatabaseInTransaction: NextFirebirdDatabase {
	
	var logger: Logger {
		self.database.logger
	}
	
	var inTransaction: Bool {
		true
	}
	
	func startTransaction() throws -> NextFirebirdDatabaseInTransaction {
		try self.database.startTransaction()
	}
	
	func commit() throws -> NextFirebirdDatabase {
		try self.transaction.commit()
		return self.database
	}
	
	func rollback() throws -> NextFirebirdDatabase {
		try self.transaction.rollback()
		return self.database
	}
	
	func query(_ queryString: String, parameters: [Encodable]) throws -> NextFirebirdQuery {
		try self.database.query(queryString, parameters: parameters)
	}
	
}

class NextFirebirdTransaction {
	
	var handle: isc_tr_handle
	
	var isActive: Bool {
		self.handle > 0
	}
	
	init(handle: isc_tr_handle) {
		self.handle = handle
	}
	
	func commit() throws {
		try withStatus { status in
			isc_commit_transaction(&status, &self.handle)
		}
	}
	
	func rollback() throws {
		try withStatus { status in
			isc_rollback_transaction(&status, &self.handle)
		}
	}
}

struct NextFirebirdQuery {
	
	let database: NextFirebirdDatabase
	let sql: String
	let binds: [Encodable]
	
	let inputDescriptor: FirebirdDescriptorArea?
	let outputDescriptor: FirebirdDescriptorArea?
	
	init(database: NextFirebirdDatabase, sql: String, binds: [Encodable], inputDescriptor: FirebirdDescriptorArea? = nil, outputDescriptor: FirebirdDescriptorArea? = nil) {
		self.database = database
		self.sql = sql
		self.binds = binds
		self.inputDescriptor = inputDescriptor
		self.outputDescriptor = outputDescriptor
	}
	
	func prepare() throws -> NextFirebirdQuery {
		let _database = self.database.inTransaction ? self.database as! NextFirebirdDatabaseInTransaction : try self.database.startTransaction()
		
		// api call
		return NextFirebirdQuery(database: _database, sql: self.sql, binds: self.binds)
	}
	
	func describe() throws -> NextFirebirdQuery {
		// api call
		return NextFirebirdQuery(database: self.database, sql: self.sql, binds: self.binds, inputDescriptor: nil, outputDescriptor: nil)
	}
	
	func run() throws {
		
	}
	
}
