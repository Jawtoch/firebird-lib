/// Row returned by a database query
public struct FirebirdRow {
	
	public enum Error: FirebirdError {
		case unknownColumn(column: String)
	}
	
	/// Index
	public let index: Int
	
	/// Fields
	public let fields: [FirebirdField]
	
	/// Columns
	public var columns: [String] {
		self.fields.map { $0.name }
	}
	
	/// Returns a Boolean value indicating whether the row contains the given column.
	/// - Parameter column: The column to find in the row.
	/// - Returns: `true` if the column was found in the row; otherwise, `false`.
	public func contains(column: String) -> Bool {
		self.columns.contains(column)
	}
	
	/// Returns the field contained in the given column.
	/// - Parameter column: The column containing the field.
	/// - Returns: The field contained in the column, or `nil` if the row does not contains the column.
	public func field(ofColumn column: String) -> FirebirdField? {
		guard self.contains(column: column) else {
			return nil
		}
		
		return self.fields.first(where: { $0.name == column }) 
	}
	
	/// Create a new instance of type `type` with field data of given column.
	/// - Parameters:
	///   - column: the column to decode
	///   - type: the type to decode to
	/// - Returns: A new instance, or an error if the row does not contains the column
	/// - Throws: If the row does not contains the column.
	/// - Throws: If the type `type` failed to initialize from the column field data.
	public func decode<T>(column: String, as type: T.Type) throws -> T where T : FirebirdDataConvertible {
		guard let field = self.field(ofColumn: column) else {
			throw Error.unknownColumn(column: column)
		}
		
		return try T.init(firebirdData: field.data)
	}

}
