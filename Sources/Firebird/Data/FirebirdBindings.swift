import CFirebird

/// Collection of `FirebirdBind`.
/// Used to pass binds to a statement
/// Wrapper of `XSQLDA` Firebird C library structure
public class FirebirdBindings {
	
	/// Version of the `XSQLDA` structure
	public struct Version: RawRepresentable {
		
		public typealias RawValue = ISC_SHORT
		
		/// Current version of the `XSQLDA` structure.
		/// Accoring to the API programming guide of Interbase, this value should be set to `SQLDA_CURRENT_VERSION`.
		/// This value is not defined in the Firebird `ibase.h`, so it is set manually to the latest version `SQLDA_VERSION1`
		public static let current = Self(rawValue: Self.RawValue(SQLDA_VERSION1))
		
		/// Version 1 of the `XSQLDA` structure
		public static let version1 = Self(rawValue: Self.RawValue(SQLDA_VERSION1))
		
		public var rawValue: RawValue
		
		public init(rawValue: RawValue) {
			self.rawValue = rawValue
		}
		
	}
	
	public typealias ReferenceType = XSQLDA
	
	/// Macro used to get the required memory space needed to store `numberOfFields` binds
	/// - Parameter numberOfFields: number of binds in the collection
	/// - Returns: the required memory space in bytes to store `numberOfFields` binds
	public static func XSQLDA_LENGTH(_ numberOfFields: Int16) -> Int {
		return MemoryLayout<ReferenceType>.size + Int(numberOfFields - 1) * MemoryLayout<FirebirdBind.ReferenceType>.size
	}
	
	/// Create a new collection of binds, allocated to store `numberOfFields` binds.
	/// This structure use static allocation, which is deallocated during the structure destructor.
	/// - Parameters:
	///   - numberOfFields: number of binds in this collection
	///   - version: version of the underlying `XSQLDA` structure.
	public init(numberOfFields: Int16, version: Version) {
		self.handle = UnsafeMutableRawPointer
			.allocate(byteCount: Self.XSQLDA_LENGTH(numberOfFields), alignment: 1)
			.assumingMemoryBound(to: Self.ReferenceType.self)
		
		self.numberOfAllocatedFields = numberOfFields
		self.version = version
	}
	
	deinit {
		self.handle.deallocate()
	}
	
	/// Handle used to access the `XSQLDA` structure allocated for the Firebird C library.
	internal let handle: UnsafeMutablePointer<ReferenceType>
	
	/// Version of the collection
	public var version: Version {
		get {
			Self.Version(rawValue: self.handle.pointee.version)
		}
		set {
			self.handle.pointee.version = newValue.rawValue
		}
	}
	
	/// Count of binds allocated in the collection
	public var numberOfAllocatedFields: Int16 {
		get {
			self.handle.pointee.sqln
		}
		set {
			self.handle.pointee.sqln = newValue
		}
	}
	
	/// Count of required binds in the collection.
	/// This value is set during statement description.
	/// Use this value to known how many binds are required by a statement.
	public var numberOfFields: Int16 {
		self.handle.pointee.sqld
	}
	
	/// List of binds in the collection.
	public var binds: [FirebirdBind] {
		let range = (0 ..< min(self.numberOfFields, self.numberOfAllocatedFields))
		return withUnsafeMutablePointer(to: &self.handle.pointee.sqlvar) { unsafeVar in
			range.map { unsafeVar.advanced(by: Int($0)) }.map { FirebirdBind(handle: $0) }
		}
	}
	
}
