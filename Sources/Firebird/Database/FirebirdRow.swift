//
//  FirebirdRow.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

import Foundation

public struct FirebirdRow {
	
	public let index: Int
	
    public let values: [String: (context: DataConvertionContext, data: Data?)]
}
