//
//  FirebirdDescriptorArea.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

public class FirebirdDescriptorArea {
	
	public var handle: XSQLDA
	
	public init() {
		self.handle = XSQLDA()
	}
	
}
