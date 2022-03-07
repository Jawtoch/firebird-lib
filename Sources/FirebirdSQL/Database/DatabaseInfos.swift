//
//  File.swift
//  
//
//  Created by ugo cottin on 04/03/2022.
//

import fbclient

public struct DatabaseInfo: RawRepresentable {
    
    public typealias RawValue = db_info_types.RawValue
	
	public static let allocation = DatabaseInfo(isc_info_allocation)
    
    public static let odsVersion = DatabaseInfo(isc_info_ods_version)
    
    public static let odsMinorVersion = DatabaseInfo(isc_info_ods_minor_version)
	
	public static let dbId = DatabaseInfo(isc_info_db_id)
    
    public var rawValue: RawValue
    
    private init(_ info: db_info_types) {
        self.rawValue = info.rawValue
    }
    
    public init?(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension DatabaseInfo: CustomStringConvertible {
	
	public var description: String {
		let text: String
		switch self {
			case .allocation:
				text = "Allocation"
			case .odsVersion:
				text = "ODS version"
			case .odsMinorVersion:
				text = "ODS minor version"
			case .dbId:
				text = "Database ID"
			default:
				text = "unknown"
		}
		
		return text
	}
	
}

extension DatabaseInfo: Equatable, Hashable { }

public struct DatabaseInfos {
    
    public typealias Element = ISC_SCHAR
    
    private var options: [DatabaseInfo] = []
    
    public var buffer: [Element] {
        self.options.map { Element($0.rawValue) }
    }
    
    mutating func append(contentOf sequence: [DatabaseInfo]) {
        for item in sequence {
            self.append(item)
        }
    }
    
    mutating func append(_ newElement: DatabaseInfo) {
        if (!self.options.contains(newElement)) {
            self.options.append(newElement)
        }
    }
    
}
