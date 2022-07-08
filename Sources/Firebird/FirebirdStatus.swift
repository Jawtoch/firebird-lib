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
