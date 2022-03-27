//
//  FirebirdODSVersionDatabaseInformation.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

import fbclient

public struct FirebirdODSVersionDatabaseInformation: FirebirdDatabaseInformation {
	
	public let rawValue: RawValue = isc_info_ods_version.rawValue
	
	public var description: String {
		"ODS Version"
	}
}
