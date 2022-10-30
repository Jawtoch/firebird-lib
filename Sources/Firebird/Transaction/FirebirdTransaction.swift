import CFirebird
import Logging

public protocol FirebirdTransaction {
	
	var logger: Logger { get }
	
	var handle: isc_tr_handle { get set }
	
	var isClosed: Bool { get }
		
	// MARK: - Prepare
	func prepare() throws
	
	func prepare(transactionMessage: String) throws
	
	// MARK: - Commit
	func commit() throws
	
	func commitRetaining() throws
	
	// MARK: - Rollback
	func rollback() throws
	
	func rollbackRetaining() throws
	
}
