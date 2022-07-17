import NIOCore
import NIOPosix
import XCTest

public class XCTestCaseInEventLoop: XCTestCase {

	public var eventLoopGroup: EventLoopGroup!
	
	public var eventLoop: EventLoop {
		self.eventLoopGroup.next()
	}
	
    override public func setUpWithError() throws {
		self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    override public func tearDown() async throws {
		try await self.eventLoopGroup.shutdownGracefully()
    }
	
}
