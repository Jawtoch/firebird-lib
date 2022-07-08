import CFirebird
import Logging
import NIOCore

public class FBTransaction: FirebirdTransaction {
	
	/// Transaction handle
	internal var handle: isc_tr_handle
	
	/// Transaction logger
	public let logger: Logger
	
	/// Transaction event loop
	public let eventLoop: EventLoop
	
	public var isClosed: Bool {
		self.handle <= 0
	}
	
	/// Create a transaction reference with given handle
	/// - Parameters:
	///   - handle: handle of a Firebird transaction
	///   - logger: transaction logger
	///   - eventLoop: transaction event loop
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

