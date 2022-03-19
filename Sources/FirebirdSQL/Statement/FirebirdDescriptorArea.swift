//
//  FirebirdDescriptorArea.swift
//  
//
//  Created by Ugo Cottin on 19/03/2022.
//

import fbclient
import Foundation

struct FirebirdDescriptorArea {
	
	typealias ReferenceType = XSQLDA
	
	let handle: UnsafeMutablePointer<ReferenceType>
	
	private var pointee: ReferenceType {
		self.handle.pointee
	}
	
	/// Indicates the version of the XSQLDA structure. Set this to SQLDA_CURRENT_VERSION, which is defined in ibase.h.
	var version: Int16 {
		self.pointee.version
	}
	
	/// Indicates the number of elements in the sqlvar array; the application should set this field whenever it allocates storage for a descriptor.
	var count: Int16 {
		self.pointee.sqln
	}
	
	/**
	 Indicates the number of parameters for an input XSQLDA, or the number of select-list items for an output XSQLDA; set during an isc_dsql_describe(), isc_dsql_describe_bind(), or isc_dsql_prepare(). For an input descriptor, a sqld of 0 indicates that the SQL statement has no parameters; for an output descriptor, a sqld of 0 indicates that the SQL statement is not a SELECT statement.
	 */
	var parametersCount: Int16 {
		self.pointee.sqld
	}
	
}
