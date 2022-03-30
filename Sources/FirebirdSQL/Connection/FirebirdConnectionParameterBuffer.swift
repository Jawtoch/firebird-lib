//
//  FirebirdConnectionParameterBuffer.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

public struct FirebirdConnectionParameterBuffer: ParameterBuffer {
	
	public typealias Parameter = FirebirdConnectionParameter
	
	public var parameters: [FirebirdConnectionParameter]
	
	public init(parameters: [FirebirdConnectionParameter] = []) {
		self.parameters = parameters
	}
	
	public mutating func add(parameter: FirebirdConnectionParameter) {
		self.parameters.append(parameter)
	}
	
}
