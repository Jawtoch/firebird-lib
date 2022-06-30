//
//  FirebirdConnection.swift
//  
//
//  Created by ugo cottin on 24/06/2022.
//

import Logging
import NIOCore

public protocol FirebirdConnection {
	
	var eventLoop: EventLoop { get }
	
	var logger: Logger { get }
	
	var isClosed: Bool { get }
	
	var configuration: FirebirdConnectionConfiguration { get }
		
	func connect() -> EventLoopFuture<Void>
	
	func close() -> EventLoopFuture<Void>
	
}
