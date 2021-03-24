//
//  Firebird.swift
//  
//
//  Created by ugo cottin on 20/03/2021.
//

public struct FirebirdConstants {
	
	public static let dialect: UInt16 = 3
	
	public static let descriptorAreaVersion: Int16 = 1
}

public extension String {
	
	static func randomString(length: Int) -> String {
		let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		return String((0..<length).map{ _ in letters.randomElement()! })
	}
	
}
