//
//  ParameterBuffer.swift
//  
//
//  Created by Ugo Cottin on 24/03/2022.
//

public protocol ParameterBuffer: Sequence {
	
	associatedtype Parameter
	
	var parameters: [Parameter] { get }
	
	mutating func add(parameter: Parameter)
	
}

public extension ParameterBuffer {
	
	func makeIterator() -> AnyIterator<Parameter> {
		var index = 0
		
		return AnyIterator {
			defer { index += 1 }
			return index < self.parameters.count ? self.parameters[index] : nil
		}
	}
	
}
