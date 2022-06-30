//
//  FirebirdConnectionParameter.swift
//
//
//  Created by ugo cottin on 24/06/2022.
//

import CFirebird

public enum FirebirdConnectionParameter: RawRepresentable {

	public typealias RawValue = [ISC_SCHAR]
		
	case version1
	case username(_: String)
	case password(_: String)
	case custom(_: RawValue)
	
	public init(rawValue: RawValue) {
		self = .custom(rawValue)
	}
	
	public var rawValue: RawValue {
		switch self {
			case .version1:
				return [ RawValue.Element(isc_dpb_version1) ]
			case .username(let username):
				let cString = username.utf8CString
				return [ RawValue.Element(isc_dpb_user_name), RawValue.Element(cString.count) ] + cString
			case .password(let password):
				let cString = password.utf8CString
				return [ RawValue.Element(isc_dpb_password), RawValue.Element(cString.count) ] + cString
			case .custom(let bytes):
				return bytes
		}
	}
}
