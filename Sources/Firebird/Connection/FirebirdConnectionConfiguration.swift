//
//  FirebirdConnectionConfiguration.swift
//  
//
//  Created by ugo cottin on 24/06/2022.
//

public struct FirebirdConnectionConfiguration {
	
	public enum Target {
		case local(path: String)
		case remote(hostName: String, port: UInt16, path: String)
		
		var attachUrl: String {
			switch self {
				case .local(let path):
					return path
				case .remote(let hostName, let port, let path):
					return "\(hostName)/\(port):\(path)"
			}
		}
	}
	
	public static var ianaPort: UInt16 { 3050 }
	
	public let target: Target
	
	public var parameters: [FirebirdConnectionParameter]
		
	public init(
		target: Target,
		parameters: [FirebirdConnectionParameter] = []) {
			self.target = target
			self.parameters = parameters
	}
	
}
