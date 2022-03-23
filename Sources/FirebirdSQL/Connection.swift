//
//  Connection.swift
//  
//
//  Created by Ugo Cottin on 23/03/2022.
//

import Logging
import fbclient

public class Connection {
	
	let logger: Logger
	
	let handle: isc_db_handle
	
	var isClosed: Bool {
		self.handle <= 0
	}
	
	public static func connect(to host: String, port: UInt16 = 3050, database: String, parameters: ConnectionParameterBuffer, logger: Logger) async throws -> Connection {
		let databaseUrl = "\(host)/\(port):\(database)"
		
		logger.debug("Opening new connection to \(databaseUrl)")
		
		var status = FirebirdVectorError.vector
		var handle: isc_stmt_handle = .zero
		
		var parametersBuffer = parameters.parameters.flatMap { $0.rawBytes }
		
		try parametersBuffer.withUnsafeMutableBufferPointer { bufferPointer in
			let bufferBaseAddress = bufferPointer.baseAddress
			guard let bufferLength = Int16(exactly: bufferPointer.count) else {
				throw FirebirdCustomError(reason: "Buffer too large")
			}
			
			try databaseUrl.withCString { cDatabaseUrl in
				if isc_attach_database(&status, Int16(databaseUrl.count), cDatabaseUrl, &handle, bufferLength, bufferBaseAddress) > 0 {
					throw FirebirdVectorError(from: status)
				}
			}
		}
			
		return Connection(handle: handle, logger: logger)
	}
	
	init(handle: isc_db_handle, logger: Logger) {
		self.logger = logger
		self.handle = handle
	}
}
