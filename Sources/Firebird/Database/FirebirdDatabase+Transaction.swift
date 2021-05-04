//
//  FirebirdDatabase+Transaction.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

fileprivate struct teb {
	var dbHandle: UnsafePointer<isc_db_handle>
	var bufferLength: CLong
	var bufferHandle: UnsafePointer<ISC_SCHAR>
	
	internal init(dbHandle: UnsafePointer<isc_db_handle>, bufferLength: CLong, bufferHandle: UnsafePointer<ISC_SCHAR>) {
		self.dbHandle = dbHandle
		self.bufferLength = bufferLength
		self.bufferHandle = bufferHandle
	}
}

public extension FirebirdDatabase {
	
	/// Start a new transaction on the connected database
	/// - Parameter connection: a opened connection
	/// - Returns: a new transaction
	func startTransaction(on connection: FirebirdConnection) throws -> FirebirdTransaction {
		
		guard connection.isOpened else {
			self.logger.warning("Trying to start a transaction on non opened connection")
			throw FirebirdCustomError("Unable to start a transaction on non opened connection to \(connection)")
		}
		
		var tebVector: [teb] = []
		var buffer = [ISC_SCHAR(isc_tpb_version3), ISC_SCHAR(isc_tpb_write)]
		
		var status = FirebirdError.statusArray
		var handle: isc_tr_handle = 0
		
		let block = teb(
			dbHandle: &connection.handle,
			bufferLength: buffer.count,
			bufferHandle: &buffer)
		tebVector.append(block)
		
		self.logger.trace("Starting a transaction on \(connection)")
		if isc_start_multiple(&status, &handle, 1, &tebVector) > 0 || handle <= 0 {
			throw FirebirdError(from: status)
		}
		self.logger.trace("Transaction started")
		return FirebirdTransaction(handle: handle)
	}
	
	func commitTransaction(_ transaction: FirebirdTransaction) throws {
		var status = FirebirdError.statusArray
		
		if isc_commit_transaction(&status, &transaction.handle) > 0 {
			throw FirebirdError(from: status)
		}
		
		self.logger.trace("Transaction \(transaction) commited")
	}
	
	func rollbackTransaction(_ transaction: FirebirdTransaction) throws {
		var status = FirebirdError.statusArray
		
		if isc_rollback_transaction(&status, &transaction.handle) > 0 {
			throw FirebirdError(from: status)
		}
		
		self.logger.trace("Transaction \(transaction) rollback")
	}
}
