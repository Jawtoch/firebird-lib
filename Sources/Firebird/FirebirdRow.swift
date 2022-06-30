//
//  FirebirdRow.swift
//  
//
//  Created by ugo cottin on 24/06/2022.
//

public struct FirebirdRow {
	
	public let index: Int
	
	public let fields: [FirebirdField]
	
	public var columns: [String] {
		self.fields.map { $0.name }
	}
	
	public func contains(column: String) -> Bool {
		self.columns.contains(column)
	}
	
	public func field(ofColumn column: String) -> FirebirdField? {
		guard self.contains(column: column) else {
			return nil
		}
		
		return self.fields.first(where: { $0.name == column }) 
	}
	
	public func decode<T>(column: String, as type: T.Type) throws -> T where T : FirebirdDataConvertible {
		guard self.contains(column: column) else {
			fatalError()
		}
		
		guard let field = self.field(ofColumn: column) else {
			fatalError()
		}
		
		return try T.init(firebirdData: field.data)
	}

}
