import Logging
import NIOCore

public protocol FirebirdDatabase {
	
	/// Database event loop
	var eventLoop: EventLoop { get }
	
	/// Database logger
	var logger: Logger { get }
	
	/// Send a query to the database
	/// - Parameters:
	///   - query: a query
	///   - binds: data to bind to the query
	/// - Returns: rows of the query result
	func query(_ query: String, binds: [FirebirdDataConvertible]) -> EventLoopFuture<[FirebirdRow]>
	
	/// Execute the closure with established connection to the database.
	/// The closure will be exectued on the database event loop.
	/// - Parameter closure: a closure
	/// - Returns: a future with the closure result
	func withConnection<T>(_ closure: @escaping (FirebirdDatabase) -> EventLoopFuture<T>) -> EventLoopFuture<T>
	
	/// Execute the closure within a transaction.
	/// When the closure succeed, the transaction is commited.
	/// When the closure fail, the transaction is rolled back
	/// The closure will be exectued on the database event loop
	/// - Parameter closure: a closure
	/// - Returns: a future with the closure result
	func withTransaction<T>(_ closure: @escaping (FirebirdDatabase) -> EventLoopFuture<T>) -> EventLoopFuture<T>
	
}
