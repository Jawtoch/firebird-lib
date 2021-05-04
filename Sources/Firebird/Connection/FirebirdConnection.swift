//
//  FirebirdConnection.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//
import Foundation

public class FirebirdConnection {
	
	/// The connection logger
	public let logger: Logger
	
	/// The connection handle
	var handle: isc_db_handle
	
	/// Create a connection
	/// - Parameters:
	///   - logger: a logger
	///   - handle: a previously opened connection, or `0` if not
	public init(logger: Logger, handle: isc_db_handle = 0) {
		self.logger = logger
		self.handle = handle
	}
	
	/// If the connection is opened
	public var isOpened: Bool {
		self.handle > 0
	}
	
	/// Create a connection to a database
	/// - Parameters:
	///   - configuration: the connection configuration
	///   - logger: a logger
	/// - Throws: if an error occur while connecting to the database
	/// - Returns: a connection to the database
	public static func connect(_ configuration: FirebirdConnectionConfiguration, logger: Logger = Logger(label: "logging.firebird")) throws -> FirebirdConnection {
		var status = FirebirdError.statusArray
		
		var dpb: [ISC_SCHAR] = []
		dpb.append(ISC_SCHAR(isc_dpb_version1))
		
		dpb.append(ISC_SCHAR(isc_dpb_user_name))
		var username = configuration.username.utf8CString
		
		if let last = username.last, last == 0 {
			username.removeLast()
		}
		
		dpb.append(ISC_SCHAR(username.count))
		dpb.append(contentsOf: username)
		
		dpb.append(ISC_SCHAR(isc_dpb_password))
		var password = configuration.password.utf8CString
		
		if let last = password.last, last == 0 {
			password.removeLast()
		}
		
		dpb.append(ISC_SCHAR(password.count))
		dpb.append(contentsOf: password)
		
		var handle: isc_db_handle = 0
		
		logger.info("Establishing connection to \(configuration)…")
		
		var attachRet: ISC_STATUS = 0
		let work = DispatchWorkItem {
			attachRet = isc_attach_database(&status, 0, configuration.databaseURL, &handle, Int16(dpb.count), dpb)
		}
		
		DispatchQueue.global(qos: .userInitiated).async(execute: work)
		if work.wait(timeout: .now() + 10) == .timedOut {
			throw FirebirdCustomError("timeout")
		} else {
			if attachRet > 0 {
				throw FirebirdError(from: status)
			}
		}
		

		logger.info("Connection established")
		
		return FirebirdConnection(logger: logger, handle: handle)
	}
	
	/// Close this connection to the database
	/// - Throws: if an error occur while closing the connection
	public func close() throws {
		guard self.isOpened else {
			self.logger.warning("Connection \(self) already closed")
			return
		}
		
		var status = FirebirdError.statusArray
		self.logger.info("Closing connection \(self)")
		
		if isc_detach_database(&status, &self.handle) > 0 {
			throw FirebirdError(from: status)
		}
		
		self.logger.info("Connection \(self) closed")
	}
}

extension FirebirdConnection: CustomStringConvertible {
	
	public var description: String { "Connection(handle: \(self.handle))" }
}
