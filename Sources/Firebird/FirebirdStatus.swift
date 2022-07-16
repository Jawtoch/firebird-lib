import CFirebird

public typealias FirebirdStatus = [ISC_STATUS]

public struct FirebirdStatusFactory: Factory {
	
	public typealias Produced = FirebirdStatus
	
	/// Length of the status vector
	public static var statusLength: Int {
		Int(ISC_STATUS_LENGTH)
	}
	
	/// Shared instance of the factory
	public static var shared: Self {
		if let instance = self.instance {
			return instance
		}
		
		let new = FirebirdStatusFactory()
		self.instance = new
		
		return new
	}
	
	/// Shared instance of the factory
	private static var instance: FirebirdStatusFactory?
	
	public func next() -> FirebirdStatus {
		.init(repeating: 0, count: Self.statusLength)
	}
}

/// Perform the closure with a FirebirdStatus.
/// - Parameter closure: a closure with a FirebirdStatus as parameter,
/// - Throws: a FirebirdNativeError if the first element of the FirebirdStatus if equal to 0 and the second element is above or equal to 0, otherwise does not throws.
func withStatus(_ closure: (inout FirebirdStatus) throws -> ()) throws {
	var status = FirebirdStatusFactory.shared.next()
	try closure(&status)
	if status[0] == 1 && status[1] > 0 {
		throw FirebirdNativeError(status: status)
	}
}
