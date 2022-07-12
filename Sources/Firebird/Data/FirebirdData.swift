import CFirebird
import Foundation

/// Contains data and metadata associated with it.
public struct FirebirdData {
	
	/// Data metadata
	public struct Metadata {
		
		/// Type of the data.
		public let type: FirebirdDataType
		
		/// Specifies the subtype for Blob data.
		public let subType: FirebirdDataType
		
		/// Scale of the bind value, used for floating point integers.
		/// Provides scale, specified as a negative number, for exact numeric data types (short, long, double or int64)
		public let scale: ISC_SHORT
		
		/// Count of bytes in the data
		public let length: ISC_SHORT
		
	}
	
	/// Data associated metadata
	public let metadata: Metadata
	
	/// Data value, if present
	public let value: Data?
	
}
