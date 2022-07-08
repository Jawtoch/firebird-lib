import CFirebird
import NIOCore
import Logging

/// Reference to a database transaction
public protocol FirebirdTransaction {
	
	/// Transaction logger
	var logger: Logger { get }
	
	/// Transaction event loop
	var eventLoop: EventLoop { get }
	
	/// Indicate if the transaction is closed (commited or rolled back)
	var isClosed: Bool { get }
	
	/// Commit the transaction
	/// - Returns: an empty future completed when the transaction is commited
	func commit() -> EventLoopFuture<Void>

	/// Rollback the transaction
	/// - Returns: an empty future completed when the transaction is rolled back
	func rollback() -> EventLoopFuture<Void>
}
