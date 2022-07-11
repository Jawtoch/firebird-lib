/// Define parameters of a `FirebirdConnection`
public struct FirebirdConnectionConfiguration {
	
	/// Target of a `FirebirdConnection`
	public enum Target {
		
		/// Connection to a local database file
		case local(path: String)
		
		/// Connection to a remote database server
		case remote(hostName: String, port: UInt16, path: String)
		
		/// String url provided to `isc_attach_database`
		var attachUrl: String {
			switch self {
				case .local(let path):
					return path
				case .remote(let hostName, let port, let path):
					return "\(hostName)/\(port):\(path)"
			}
		}
	}
	
	/// IANA assigned port to GDS-DB service
	/// See: https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml?search=GDS
	public static var ianaPort: UInt16 { 3050 }
	
	/// Connection target
	public let target: Target
	
	/// Connection parameters
	public var parameters: [FirebirdConnectionParameter]
	
	/// Hold configuration for creating a connection
	/// - Parameters:
	///   - target: connection target
	///   - parameters: connection parameters
	public init(
		target: Target,
		parameters: [FirebirdConnectionParameter] = []) {
			self.target = target
			self.parameters = parameters
	}
	
}
