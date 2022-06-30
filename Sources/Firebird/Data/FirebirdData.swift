//
//  FirebirdData.swift
//  
//
//  Created by ugo cottin on 26/06/2022.
//

import CFirebird
import Foundation

public struct FirebirdData {
	
	public struct Metadata {
		
		public let type: FirebirdDataType
		
		public let subType: FirebirdDataType
		
		public let scale: ISC_SHORT
		
		public let length: ISC_SHORT
		
	}
	
	public let metadata: Metadata
	
	public let value: Data?
	
}
