import CFirebird

/// Parameter for connection
public enum FirebirdConnectionParameter: RawRepresentable {

	public typealias RawValue = [ISC_SCHAR]
		
	/// Version of the parameter buffer, required.
	case version1
	
	/// String user name, up to 255 characters.
	case username(_: String)
	
	/// String password, up to 255 characters.
	case password(_: String)
	
	/// Custom value.
	/// Use this case for non implemented parameter or for debugging or testing
	case custom(_: RawValue)
	
	/// Initialize a parameter with given bytes.
	/// - Parameter rawValue: parameter value
	public init(rawValue: RawValue) {
		self = .custom(rawValue)
	}
	
	/// Raw bytes of the parameter
	public var rawValue: RawValue {
		switch self {
			case .version1:
				return [ RawValue.Element(isc_dpb_version1) ]
			case .username(let username):
				let cString = username.utf8CString
				return [ RawValue.Element(isc_dpb_user_name), RawValue.Element(cString.count) ] + cString
			case .password(let password):
				let cString = password.utf8CString
				return [ RawValue.Element(isc_dpb_password), RawValue.Element(cString.count) ] + cString
			case .custom(let bytes):
				return bytes
		}
	}
}
