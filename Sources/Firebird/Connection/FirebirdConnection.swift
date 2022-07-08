import Logging
import NIOCore

public protocol FirebirdConnection {
	
	/// Connection event loop
	var eventLoop: EventLoop { get }
	
	/// Connection logger
	var logger: Logger { get }
	
	/// Return a boolean indicating if the connection is closed
	var isClosed: Bool { get }
	
	/// Connection configuration
	var configuration: FirebirdConnectionConfiguration { get }
	
	/// Open the connection to target defined in `configuration`
	/// - Returns: an empty future completed when the connection is established
	func connect() -> EventLoopFuture<Void>
	
	/// Close the connection
	/// - Returns: an empty future completed when the connection is closed
	func close() -> EventLoopFuture<Void>
	
}
