//
//  XCTestCaseInEventLoop.swift
//  
//
//  Created by ugo cottin on 30/06/2022.
//

import XCTest
import NIOCore
import NIOPosix

class XCTestCaseInEventLoop: XCTestCase {

	var eventLoopGroup: EventLoopGroup!
	
	var eventLoop: EventLoop {
		self.eventLoopGroup.next()
	}
	
    override func setUpWithError() throws {
		self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    override func tearDown() async throws {
		try await self.eventLoopGroup.shutdownGracefully()
    }
	
}
