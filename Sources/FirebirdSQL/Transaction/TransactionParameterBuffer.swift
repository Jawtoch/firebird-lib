//
//  TransactionParameterBuffer.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

public struct TransactionParameterBuffer: ParameterBuffer {
	
	public typealias Parameter = TransactionParameter
	
	public var parameters: [TransactionParameter] = []
	
	public mutating func add(parameter: TransactionParameter) {
		self.parameters.append(parameter)
	}
}
