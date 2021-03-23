//
//  FirebirdDatabaseHost.swift
//  
//
//  Created by Ugo Cottin on 06/03/2021.
//

import Foundation

public struct FirebirdDatabaseHost: CustomStringConvertible {
	
	public static let defaultPort: UInt16 = 3050
	
	let hostname: String
	private let _port: UInt16?
	
	var port: UInt16 {
		self._port ?? Self.defaultPort
	}
	
	public var description: String {
		"\(hostname)/\(port)"
	}
	
	public init(hostname: String, port: UInt16? = nil) {
		self.hostname = hostname
		self._port = port
	}
	
}
