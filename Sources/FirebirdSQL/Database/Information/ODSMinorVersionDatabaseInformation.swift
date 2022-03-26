//
//  ODSMinorVersionDatabaseInformation.swift
//  
//
//  Created by ugo cottin on 04/03/2022.
//

import fbclient

public struct ODSMinorVersionDatabaseInformation: DatabaseInformation {
	
	public let rawValue: RawValue = isc_info_ods_minor_version.rawValue
	
	public var description: String {
		"ODS Minor Version"
	}
}
