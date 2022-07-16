import CFirebird
import Foundation

public struct FirebirdField {
	
	public let name: String
	
	public let originalName: String
	
	public let tableOwner: String
	
	public let tableName: String
		
	public let data: FirebirdData
	
	public init(name: String,
				originalName: String,
				tableOwner: String,
				tableName: String,
				data: FirebirdData) {
		self.name = name
		self.originalName = originalName
		self.tableOwner = tableOwner
		self.tableName = tableName
		self.data = data
	}
	
}
