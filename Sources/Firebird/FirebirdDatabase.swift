//
//  FirebirdDatabase.swift
//  
//
//  Created by ugo cottin on 24/06/2022.
//

import Logging
import NIOCore

public protocol FirebirdDatabase {
	
	var eventLoop: EventLoop { get }
	
	var logger: Logger { get }
	
	func query(_ query: String, binds: [FirebirdDataConvertible]) -> EventLoopFuture<[FirebirdRow]>
	
	func withConnection<T>(_ closure: @escaping (FirebirdDatabase) -> EventLoopFuture<T>) -> EventLoopFuture<T>
	
	func withTransaction<T>(_ closure: @escaping (FirebirdDatabase) -> EventLoopFuture<T>) -> EventLoopFuture<T>
	
}
