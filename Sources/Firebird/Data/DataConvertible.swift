//
//  File.swift
//  
//
//  Created by ugo cottin on 02/03/2022.
//

import Foundation

public protocol DataConvertible {
    
    init?(_ data: Data, using context: DataConvertionContext)
    
    func data(in context: DataConvertionContext) -> Data?
}

extension String: DataConvertible {
    
    public func data(in context: DataConvertionContext) -> Data? {
        self.data(using: .utf8)
    }
    
    
    public init?(_ data: Data, using context: DataConvertionContext) {
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
