import CFirebird
import Logging
import NIOCore

public class FBConnection: FirebirdConnection {
	
	public let eventLoop: EventLoop
	
	public let logger: Logger
	
	public var isClosed: Bool {
		self.handle <= 0
	}
	
	public let configuration: FirebirdConnectionConfiguration
	
	/// Handle used to manage the connection with the Firebird C library.
	/// This handle should only be changed by the Firebird C library.
	/// Setting this value manualy can lead to unpredictable behaviours.
	internal var handle: isc_db_handle
	
	/// Create a non connected connection.
	/// - Parameters:
	///   - configuration: connection configuration.
	///   - logger: a logger where the connection events will be logged.
	///   - eventLoop: the event loop to run the connection on.
	public init(configuration: FirebirdConnectionConfiguration, logger: Logger, on eventLoop: EventLoop) {
		self.logger = logger
		self.eventLoop = eventLoop
		self.configuration = configuration
		self.handle = 0
	}
	
	public func connect() -> EventLoopFuture<Void> {
		let parametersBuffer = self.configuration.parameters.flatMap { $0.rawValue }
		let attachUrl = self.configuration.target.attachUrl
		self.logger.debug("Opening new connection")
		
		return self.eventLoop.submit {
			try parametersBuffer.withUnsafeBufferPointer { unsafeParametersBuffer in
				try withStatus { status in
					isc_attach_database(
						&status,
						0,
						attachUrl,
						&self.handle,
						Int16(unsafeParametersBuffer.count),
						unsafeParametersBuffer.baseAddress)
				}
			}
		}.map {
			self.logger.debug("Connection \(self.handle) open")
		}
	}
	
	public func close() -> EventLoopFuture<Void> {
		let id = self.handle
		
		guard !self.isClosed else {
			self.logger.warning("Trying to close closed connection")
			return self.eventLoop.makeSucceededVoidFuture()
		}
		
		self.logger.debug("Closing connection \(id)")
		return self.eventLoop.submit {
			try withStatus { isc_detach_database(&$0, &self.handle) }
		}.map {
			self.logger.debug("Connection \(id) closed")
		}
	}
	
	/// Open a new transaction on the connection event loop.
	/// - Returns: a future opened transaction
	public func startTransaction() -> EventLoopFuture<FBTransaction> {
		self.eventLoop.submit {
			try withUnsafePointer(to: &self.handle) { unsafeHandle in
				let block = TEB(
					database: unsafeHandle,
					count: 0,
					parameters: nil)
				
				var blocks = [ block ]
				var transactionHandle: isc_tr_handle = 0
				self.logger.info("Starting new transaction")
				try withStatus { status in
					isc_start_multiple(&status, &transactionHandle, Int16(blocks.count), &blocks[0])
				}
				self.logger.info("Transaction \(transactionHandle) started")
				
				return FBTransaction(handle: transactionHandle, logger: self.logger, on: self.eventLoop)
			}
		}
	}
	
	/// Perform the closure with a transaction. The transaction is ready to be used by the closure.
	/// If the closure perform without errors, the transaction is commited, else the transaction is rolled back.
	/// - Parameter closure: a closure
	/// - Returns: the closure result
	public func withTransaction<T>(_ closure: @escaping (FBTransaction) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.startTransaction().flatMap { transaction in
			closure(transaction)
				.flatMap { result in
					transaction
						.commit()
						.map { result }
				}.flatMapError { error in
					transaction
						.rollback()
						.flatMapThrowing { throw error }
				}
		}
	}
	
}
