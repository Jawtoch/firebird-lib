import NIOCore

extension FBConnection: FirebirdDatabase {
	
	public func query(_ query: String, binds: [FirebirdDataConvertible] = []) -> EventLoopFuture<[FirebirdRow]> {
		guard !self.isClosed else {
			return self.withConnection { connection in
				connection.query(query, binds: binds)
			}
		}
		
		return self.withTransaction { (transaction: FBTransaction) in
			self.eventLoop.submit {
				let statement = FBReusableStatement(
					query: query,
					dialect: .current,
					logger: self.logger)
				
				try statement.allocate(on: self)
				try statement.prepare(on: transaction)
				
				let pool = FBAllocationPool()
				
				let inputBindings = try statement.describeInput()
				inputBindings.binds.forEach { pool.allocate(bind: $0) }
				
				for (parameter, bind) in zip(binds, inputBindings.binds) {
					let parameterData = try parameter.firebirdData(metadata: FirebirdData.Metadata(
						type: bind.type,
						subType: bind.subType,
						scale: bind.scale,
						length: bind.length))
					try bind.setData(parameterData)
				}
				
				let outputBindings = try statement.describeOutput()
				outputBindings.binds.forEach { pool.allocate(bind: $0) }
				
				try statement.execute(on: transaction, input: inputBindings)
				
				var cursor = try statement.openCursor("S", output: outputBindings)
				
				let rows = try cursor.fetchAll()
				
				pool.release()
				
				try cursor.close()
				try statement.close()
				
				return rows
			}
		}
	}
	
	public func withConnection<T>(_ closure: @escaping (FirebirdDatabase) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		guard self.isClosed else {
			// already active
			return closure(self)
		}
		
		return self
		// open connection
			.connect()
		// perform closure
			.flatMap { closure(self) }
			.flatMap { result in
				return self
				// close
					.close()
				// return closure result
					.map { result }
			}
	}
	
	public func withTransaction<T>(_ closure: @escaping (FirebirdDatabase) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		guard !self.isClosed else {
			return self.withConnection { connection in
				connection.withTransaction(closure)
			}
		}
		
		return self.withTransaction { (_: FirebirdTransaction) in
			closure(self)
		}
	}
	
}
