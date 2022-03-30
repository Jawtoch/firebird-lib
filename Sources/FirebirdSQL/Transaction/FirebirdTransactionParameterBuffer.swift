//
//  FirebirdTransactionParameterBuffer.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

public struct FirebirdTransactionParameterBuffer: ParameterBuffer {
	
	public typealias Parameter = FirebirdTransactionParameter
	
	public var parameters: [FirebirdTransactionParameter]
	
	public init(parameters: [FirebirdTransactionParameter] = []) {
		self.parameters = parameters
	}
	
	public mutating func add(parameter: FirebirdTransactionParameter) {
		self.parameters.append(parameter)
	}
}
