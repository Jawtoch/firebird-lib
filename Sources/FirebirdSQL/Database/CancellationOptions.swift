//
//  CancellationOptions.swift
//  
//
//  Created by ugo cottin on 01/12/2021.
//

import fbclient

public struct CancellationOptions: RawRepresentable {
	public typealias RawValue = Int32
	
	public static let disable = CancellationOptions(rawValue: fb_cancel_disable)
	
	public static let enable = CancellationOptions(rawValue: fb_cancel_enable)
	
	public static let raise = CancellationOptions(rawValue: fb_cancel_raise)
	
	public static let abort = CancellationOptions(rawValue: fb_cancel_abort)
	
	public let rawValue: RawValue
	
	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}
}
