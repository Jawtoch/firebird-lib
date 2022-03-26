//
//  ConnectionParameterBuffer.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

public struct ConnectionParameterBuffer: ParameterBuffer {
	
	public typealias Parameter = ConnectionParameter
	
	public var parameters: [ConnectionParameter] = []
	
	public mutating func add(parameter: ConnectionParameter) {
		self.parameters.append(parameter)
	}
	
}
