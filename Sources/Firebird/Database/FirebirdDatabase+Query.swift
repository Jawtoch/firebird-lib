//
//  FirebirdDatabase.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

public extension FirebirdDatabase {
	func simpleQuery(_ query: String, _ binds: [FirebirdData] = []) throws {
		return try self.withConnection { connection in
			
			self.logger.info("Query \(query)")
			
			// Create a new transaction
			let transaction = try self.startTransaction(on: connection)
			
			// Create a new statement
			let statement = FirebirdStatement(query, logger: self.logger)
			
			// Allocate the statement on the connection
			try statement.allocate(on: connection)
			
			// Prepare the statement with the transaction
			try self.prepare(statement, with: transaction)
			
			let numberOfParameters = query.components(separatedBy: "?").count - 1
			guard numberOfParameters == binds.count else {
				throw FirebirdCustomError("Expected \(numberOfParameters) parameters, actual \(binds.count)")
			}
			
			// Getting input descriptor area of the statement
			let inputArea: FirebirdDescriptorArea?
			if query.contains("?") {
				inputArea = try statement.describeInput()
				
				for (index, variable) in inputArea!.variables.enumerated() {
					let bind = binds[index]
					variable.data = bind.value
					
					if variable.nullable {
						variable.nullIndicatorPointer.pointee = (bind.value == nil ? -1 : 0)
					}
				}
			} else {
				inputArea = nil
			}

			// Execute the statement
			try self.execute(statement, with: transaction, inputDescriptorArea: inputArea)
			
			inputArea?.handle.deallocate()
			
			// Closing the statement
			try statement.free(.drop)
			
			// Commit the transaction
			try self.commitTransaction(transaction)
		}
	}
	
	func query(_ query: String, _ binds: [FirebirdData] = [], onRow: @escaping (FirebirdRow) throws -> Void) throws {
		return try self.withConnection { connection in
			
			self.logger.info("Query \(query)")
			
			// Create a new transaction
			let transaction = try self.startTransaction(on: connection)
			
			// Create a new statement
			let statement = FirebirdStatement(query, logger: self.logger)
			
			// Allocate the statement on the connection
			try statement.allocate(on: connection)
			
			// Prepare the statement with the transaction
			try self.prepare(statement, with: transaction)
			
			let numberOfParameters = query.components(separatedBy: "?").count - 1
			guard numberOfParameters == binds.count else {
				throw FirebirdCustomError("Expected \(numberOfParameters) parameters, actual \(binds.count)")
			}
			
			// Getting input descriptor area of the statement
			let inputArea: FirebirdDescriptorArea?
			if query.contains("?") {
				inputArea = try statement.describeInput()
				
				for (index, variable) in inputArea!.variables.enumerated() {
					let bind = binds[index]
					variable.data = bind.value
					
					if variable.nullable {
						variable.nullIndicatorPointer.pointee = (bind.value == nil ? -1 : 0)
					}
				}
			} else {
				inputArea = nil
			}
			
			// Getting output descriptor area of the statement
			let outputArea = try statement.describeOutput()
			
			// Execute the statement
			try self.execute(statement, with: transaction, inputDescriptorArea: inputArea)
			
			// Open a cursor
			let _ = try statement.openCursor()
			
			// Fetch data using the cursor
			try self.fetch(statement, outputDescriptorArea: outputArea) { try onRow($0) }
			
			inputArea?.handle.deallocate()
			outputArea.handle.deallocate()
			
			// Closing the statement
			try statement.free()
			
			// Commit the transaction
			try self.commitTransaction(transaction)
		}
	}
	
	func query(_ query: String, _ binds: [FirebirdData] = []) throws -> [FirebirdRow] {
		var rows: [FirebirdRow] = []
		try self.query(query, binds) { rows.append($0) }
		return rows
	}
	
	func execute(_ statement: FirebirdStatement, with transaction: FirebirdTransaction, inputDescriptorArea: FirebirdDescriptorArea? = nil) throws {
		var status = FirebirdError.statusArray
		let descriptorAreaVersion = inputDescriptorArea?.version ?? FirebirdConstants.descriptorAreaVersion
		
		let handle = inputDescriptorArea?.handle

		if isc_dsql_execute(&status, &transaction.handle, &statement.handle, UInt16(descriptorAreaVersion), handle) > 0 {
			isc_print_status(&status)
			throw FirebirdError(from: status)
		}
		
		self.logger.info("Statement \(statement) executed")
	}
	
	func fetch(_ statement: FirebirdStatement, outputDescriptorArea: FirebirdDescriptorArea, onRow: @escaping (FirebirdRow) throws -> Void) rethrows {
		var status = FirebirdError.statusArray
		var index = 0
		
		while case let fetchStatus = isc_dsql_fetch(&status, &statement.handle, statement.dialect, outputDescriptorArea.handle), fetchStatus == 0 {
			var values: [String: FirebirdData] = [:]
			for variable in outputDescriptorArea.variables {
				values[variable.name] = FirebirdData(type: variable.type, value:  variable.data)
			}
			
			try onRow(FirebirdRow(index: index, values: values))
			
			index += 1
		}
	}
	
	func fetch(_ statement: FirebirdStatement, outputDescriptorArea: FirebirdDescriptorArea) throws -> [FirebirdRow] {
		var rows: [FirebirdRow] = []
		self.fetch(statement, outputDescriptorArea: outputDescriptorArea) { rows.append($0) }
		return rows
	}
}
