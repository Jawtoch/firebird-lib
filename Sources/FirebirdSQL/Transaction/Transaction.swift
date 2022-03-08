//
//  Transaction.swift
//  
//
//  Created by ugo cottin on 08/03/2022.
//

import fbclient

struct Transaction {
	
	typealias Option = CChar
	
	var handle: isc_tr_handle
	
	var options: [Option]
	
	init() {
		self.handle = .zero
		self.options = []
	}
	
	mutating func addOptions(_ options: [Option]) {
		for option in options {
			self.addOption(option)
		}
	}
	
	mutating func addOption(_ option: Option) {
		if !self.options.contains(option) {
			self.options.append(option)
		}
	}
	
	mutating func prepare() throws {
		
	}
	
	mutating func start(on database: Database) throws {
		var status = FirebirdError.statusArray
		var database = database
		
		try withUnsafePointer(to: &database.handle) { databaseHandle in
			let optionsCount = self.options.count
			try self.options.withUnsafeBufferPointer { optionsPointer in
				let block = TransactionExistenceBlock(
					database: databaseHandle,
					count: optionsCount,
					parameters: optionsPointer)
				
				var blocks = [block]
				let blocksCount = blocks.count
				try blocks.withUnsafeMutableBufferPointer { blocksPointer in
					let rawBlocksPointer = UnsafeMutableRawBufferPointer(blocksPointer)
					
					guard let blocksAddress = rawBlocksPointer.baseAddress else {
						fatalError()
					}
					
					if isc_start_multiple(&status, &self.handle, Int16(blocksCount), blocksAddress) > 0 {
						throw FirebirdError(from: status)
					}
				}
				
			}
		}
	}
	
	mutating func commit() throws {
		
	}
	
	mutating func rollback() throws {
		
	}
}
