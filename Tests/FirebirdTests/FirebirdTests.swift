import Firebird
import Foundation

private func requireEnv(_ name: String) -> String {
	guard let value = ProcessInfo.processInfo.environment[name] else {
		fatalError("The environment variable \(name) must be set")
	}
	
	return value
}

final class FirebirdTests {
    	
	static var hostname: String {
		requireEnv("FB_TEST_HOSTNAME")
	}
	
	static var port: UInt16 {
		UInt16(requireEnv("FB_TEST_PORT"))!
	}
	
	static var path: String {
		requireEnv("FB_TEST_DATABASE")
	}
	
	static var username: String {
		requireEnv("FB_TEST_USERNAME")
	}
	
	static var password: String {
		requireEnv("FB_TEST_PASSWORD")
	}
	
	static var databaseTarget: FirebirdConnectionConfiguration.Target {
		.remote(
			hostName: self.hostname,
			port: self.port,
			path: self.path)
	}
	
	static var configuration: FirebirdConnectionConfiguration {
		.init(
			target: self.databaseTarget,
			parameters: [
				.version1,
				.username(self.username),
				.password(self.password)
			])
	}
	
}
