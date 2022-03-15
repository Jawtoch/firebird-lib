//
//  FirebirdTransaction.swift
//  
//
//  Created by ugo cottin on 08/03/2022.
//

import fbclient

class FirebirdTransaction {
	
	var handle: isc_tr_handle
	
	var status: [ISC_STATUS]
	
	var isStarted: Bool {
		self.handle > 0
	}
	
	var options: [FirebirdTransactionOption]
	
	init() {
		self.handle = 0
		self.status = FirebirdVectorError.vector
		self.options = []
	}
	
	func addOption(_ option: FirebirdTransactionOption) {
		self.options.append(option)
	}
	
	func addOptions(_ options: [FirebirdTransactionOption]) {
		options.forEach { self.options.append($0) }
	}
	
	func prepare() throws {
		if isc_prepare_transaction(&self.status, &self.handle) > 0 {
			throw FirebirdVectorError(from: self.status)
		}
	}
	
	func start(on database: FirebirdDatabase) throws {		
		let optionsBuffer = self.options.flatMap { $0.buffer }
		let optionsCount = optionsBuffer.count
		
		try withUnsafeMutablePointer(to: &database.handle) { databaseHandle in
			try optionsBuffer.withUnsafeBufferPointer { optionsPointer in
				let block = TransactionExistenceBlock(
					database: databaseHandle,
					count: optionsCount,
					parameters: optionsPointer)
				
				var blocks = [ block ]
				let blocksCount = blocks.count
				try blocks.withUnsafeMutableBufferPointer { blocksPointer in
					let rawBlocksPointer = UnsafeMutableRawBufferPointer(blocksPointer)
					
					guard let blocksAddress = rawBlocksPointer.baseAddress else {
						fatalError()
					}
					
					if isc_start_multiple(&self.status, &self.handle, Int16(blocksCount), blocksAddress) > 0 {
						throw FirebirdVectorError(from: status)
					}
				}
			}
		}
	}
	
	func commit() throws {
		if isc_commit_transaction(&self.status, &self.handle) > 0 {
			throw FirebirdVectorError(from: self.status)
		}
	}
	
	func rollback() throws {
		if isc_rollback_transaction(&self.status, &self.handle) > 0 {
			throw FirebirdVectorError(from: self.status)
		}
	}
}
