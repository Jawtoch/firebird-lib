import Foundation

public protocol FirebirdDataConvertible {
	
	/// Decode value with `FirebirdData`, using this value and the provided metadata
	/// - Parameter firebirdData: data
	/// - Throws: if the value cannot be decoded
	init(firebirdData: FirebirdData) throws
	
	/// - Parameter metadata: the metadata for the data
	/// - Returns: encoded value as data for given metadata
	/// - Throws: if the value cannot be encoded
	func firebirdData(metadata: FirebirdData.Metadata) throws -> Data?
}
