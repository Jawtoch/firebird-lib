import CFirebird
import Foundation

/// Wrapper of XSQLVAR data structure
/// Used to bind data to a query placeholder
public class FirebirdBind {
	
	public enum Error: FirebirdError {
		case noDataStorage
		case noNilStorage
		case valueNotNullable
	}
	
	/// Underlying Firebird type
	public typealias ReferenceType = XSQLVAR
	
	/// Handle used to access the `XSQLVAR` structure allocated for the Firebird C library.
	public let handle: UnsafeMutablePointer<ReferenceType>
	
	/// Bind with data at given memory pointer
	/// - Parameter handle: Pointer to allocated memory of type `ReferenceType`
	public init(handle: UnsafeMutablePointer<ReferenceType>) {
		self.handle = handle
	}
	
	/// Type of the bind value.
	public var type: FirebirdDataType {
		get {
			FirebirdDataType(rawValue: self.handle.pointee.sqltype)!
		}
		set {
			self.handle.pointee.sqltype = ISC_SHORT(newValue.rawValue)
		}
	}
	
	/// Specifies the subtype for Blob data.
	public var subType: FirebirdDataType {
		get {
			FirebirdDataType(rawValue: self.handle.pointee.sqlsubtype)!
		}
		set {
			self.handle.pointee.sqlsubtype = ISC_SHORT(newValue.rawValue)
		}
	}
	
	/// Scale of the bind value, used for floating point integers.
	/// Provides scale, specified as a negative number, for exact numeric data types (short, long, double or int64)
	public var scale: ISC_SHORT {
		get {
			self.handle.pointee.sqlscale
		}
		set {
			self.handle.pointee.sqlscale = newValue
		}
	}
	
	/// Count of bytes in the data
	public var length: ISC_SHORT {
		get {
			self.handle.pointee.sqllen
		}
		set {
			self.handle.pointee.sqllen = newValue
		}
	}
	
	/// Name of the column defined in the query
	public var name: String {
		String(cString: &self.handle.pointee.aliasname.0)
	}
	
	/// Name of the column in the database
	public var originalName: String {
		String(cString: &self.handle.pointee.sqlname.0)
	}
	
	/// Name of the table owner
	public var tableOwner: String {
		String(cString: &self.handle.pointee.ownname.0)
	}
	
	/// Name of the table
	public var tableName: String {
		String(cString: &self.handle.pointee.relname.0)
	}
	
	/// Count of bytes in the data, with the metadata (used of varying strings)
	public var size: Int16 {
		self.length + (self.type == .varying ? 2 : 0)
	}
	
	/// Pointer to an allocated memory for storing bind data value
	public var unsafeDataStorage: UnsafeMutablePointer<ISC_SCHAR>? {
		get {
			self.handle.pointee.sqldata
		}
		set {
			self.handle.pointee.sqldata = newValue
		}
	}
	
	/// Pointer to an allocated memory for storing nil indicating value
	public var unsafeNilStorage: UnsafeMutablePointer<ISC_SHORT>? {
		get {
			self.handle.pointee.sqlind
		}
		set {
			self.handle.pointee.sqlind = newValue
		}
	}
	
	/// Get the data stored in the bind.
	/// If the value is nullable, a storage for the nil indicator value is required
	/// - Returns: the data stored in the bind
	/// - Throws: if no storage is provided for data and / or nil indicator value
	public func getData() throws -> Data? {
		if self.type.isNullable {
			guard let unsafeNilStorage = self.unsafeNilStorage else {
				throw Error.noNilStorage
			}
			
			if unsafeNilStorage.pointee == -1 {
				return nil
			}
		}
		
		guard let unsafeDataStorage = self.unsafeDataStorage else {
			throw Error.noDataStorage
		}
		
		return Data(bytes: unsafeDataStorage, count: Int(self.size))

	}
	
	/// Set the bind data.
	/// If the value is nullable, a storage for the nil indicator value is required
	/// - Parameter data: bind data
	/// - Throws: if no storage is provided for data and / or nil indicator value.
	public func setData(_ data: Data?) throws {
		if let data = data {
			guard let unsafeDataStorage = self.unsafeDataStorage else {
				throw Error.noDataStorage
			}
			
			let dataSize = min(data.count, Int(self.size))
			unsafeDataStorage.withMemoryRebound(to: Data.Element.self, capacity: dataSize) { data.copyBytes(to: $0, count: dataSize) }
			
			if self.type.isNullable {
				guard let unsafeNilStorage = self.unsafeNilStorage else {
					throw Error.noNilStorage
				}

				unsafeNilStorage.pointee = -1
			}
		} else {
			guard self.type.isNullable else {
				throw Error.valueNotNullable
			}
			
			guard let unsafeNilStorage = self.unsafeNilStorage else {
				throw Error.noNilStorage
			}
			
			unsafeNilStorage.pointee = -1
		}
	}
	
}
