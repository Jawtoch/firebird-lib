//
//  FirebirdDatabase+Transaction.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

fileprivate struct ISC_TEB {
	let dbb_ptr: UnsafePointer<isc_db_handle>
	let tpb_len: CLong
	let tpb_ptr: UnsafeBufferPointer<ISC_SCHAR>
}

public extension FirebirdDatabase {
	
	/// Start a new transaction on the connected database
	/// - Parameter connection: a opened connection
	/// - Returns: a new transaction
	func startTransaction(on connection: FirebirdConnection) throws -> FirebirdTransaction {
		
		guard connection.isOpened else {
			self.logger.warning("Trying to start a transaction on non opened connection")
			throw FirebirdCustomError(reason: "Unable to start a transaction on non opened connection to \(connection)")
		}
		
		let buffer = [ISC_SCHAR(isc_tpb_version3), ISC_SCHAR(isc_tpb_write)]
		
		var status = FirebirdVectorError.vector
		var handle: isc_tr_handle = 0

		return try withUnsafePointer(to: connection.handle) { conn_ptr in
			try buffer.withUnsafeBufferPointer { buffer_ptr in
				var tebVector: [ISC_TEB] = []
				let isc_teb = ISC_TEB(
					dbb_ptr: conn_ptr,
					tpb_len: buffer.count,
					tpb_ptr: buffer_ptr)
				
				tebVector.append(isc_teb)
				
				if isc_start_multiple(&status, &handle, 1, &tebVector) > 0 || handle <= 0 {
					throw FirebirdVectorError(from: status)
				}
				self.logger.trace("Transaction started")
				return FirebirdTransaction(handle: handle)
			}
		}
	}
	
	func commitTransaction(_ transaction: FirebirdTransaction) throws {
		var status = FirebirdVectorError.vector
		
		if isc_commit_transaction(&status, &transaction.handle) > 0 {
			throw FirebirdVectorError(from: status)
		}
		
		self.logger.trace("Transaction \(transaction) commited")
	}
	
	func rollbackTransaction(_ transaction: FirebirdTransaction) throws {
		var status = FirebirdVectorError.vector
		
		if isc_rollback_transaction(&status, &transaction.handle) > 0 {
			throw FirebirdVectorError(from: status)
		}
		
		self.logger.trace("Transaction \(transaction) rollback")
	}
}
