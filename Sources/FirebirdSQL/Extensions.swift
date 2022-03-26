//
//  Extensions.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

import Foundation

internal extension Data {
	
	func hexString(separator: String = "") -> String {
		self.map { String(format: "%02x", $0) }.joined(separator: separator)
	}
	
}
