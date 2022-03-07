//
//  File.swift
//  
//
//  Created by ugo cottin on 02/03/2022.
//

import Foundation

public protocol DataConvertible {
    
    init?(_ data: Data, using context: DataConvertionContext)
    
    func data(accordingTo context: DataConvertionContext) -> Data?
}

extension String: DataConvertible {
    
    public func data(accordingTo context: DataConvertionContext) -> Data? {
        self.data(using: .utf8)
    }
    
    
    public init?(_ data: Data, using context: DataConvertionContext) {
        self.init(bytes: data, encoding: .utf8)
    }
    
}
