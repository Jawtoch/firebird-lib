//
//  File.swift
//  
//
//  Created by ugo cottin on 02/03/2022.
//

import Foundation

public protocol FirebirdDataConvertible: Codable {
    
    init?(_ data: Data, using context: FirebirdDataConvertionContext)
    
    func data(in context: FirebirdDataConvertionContext) -> Data?
}

extension String: FirebirdDataConvertible {
    
    public func data(in context: FirebirdDataConvertionContext) -> Data? {
		guard var size = Int16(exactly: self.count) else {
			// String too long
			return nil
		}
		
		var data = withUnsafeBytes(of: &size) { Data($0) }
		let paddedSelf = self.padding(toLength: context.size - 2, withPad: "\0", startingAt: 0)
		guard let stringData = paddedSelf.data(using: .utf8) else {
			// Unable to encode
			return nil
		}
		
		data.append(stringData)
		return data
    }
    
    
    public init?(_ data: Data, using context: FirebirdDataConvertionContext) {
		if context.dataType == .varying {
			let sizeBytes = data.prefix(2)
			let size = Int(sizeBytes.withUnsafeBytes { $0.load(as: Int16.self) })
			let buffer = data
				.dropFirst(2)
				.prefix(size)
			self.init(bytes: buffer, encoding: .utf8)
		} else {
			self.init(bytes: data, encoding: .utf8)
		}
        
    }
    
}
