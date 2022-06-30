//
//  FirebirdTransaction.swift
//  
//
//  Created by ugo cottin on 24/06/2022.
//

import CFirebird
import NIOCore
import Logging

public protocol FirebirdTransaction {
	
	var logger: Logger { get }
	
	var eventLoop: EventLoop { get }
	
	var isClosed: Bool { get }
	
	func commit() -> EventLoopFuture<Void>
	
	func rollback() -> EventLoopFuture<Void>
}

public class FBTransaction: FirebirdTransaction {
	
	internal var handle: isc_tr_handle
	
	public let logger: Logger
	
	public let eventLoop: EventLoop
	
	public var isClosed: Bool {
		self.handle <= 0
	}
	
	public init(handle: isc_tr_handle, logger: Logger, on eventLoop: EventLoop) {
		self.handle = handle
		self.logger = logger
		self.eventLoop = eventLoop
	}
	
	public func commit() -> EventLoopFuture<Void> {
		guard !self.isClosed else {
			self.logger.warning("Trying to commit closed transaction")
			return self.eventLoop.makeSucceededVoidFuture()
		}
		
		let id = self.handle
		self.logger.info("Commit transaction \(id)")
		return self.eventLoop.submit {
			try withStatus { status in
				isc_commit_transaction(&status, &self.handle)
			}
		}.map {
			self.logger.info("Transaction \(id) committed")
		}
	}
	
	public func rollback() -> EventLoopFuture<Void> {
		guard !self.isClosed else {
			self.logger.warning("Trying to rollback closed transaction")
			return self.eventLoop.makeSucceededVoidFuture()
		}
		
		let id = self.handle
		self.logger.info("Rollback transaction \(id)")
		return self.eventLoop.submit {
			try withStatus { status in
				isc_rollback_transaction(&status, &self.handle)
			}
		}.map {
			self.logger.info("Transaction \(id) rolled back")
		}
	}
	
}
