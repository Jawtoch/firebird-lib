//
//  FirebirdSQLVariable.swift
//  
//
//  Created by Ugo Cottin on 19/03/2022.
//

import fbclient

struct FirebirdSQLVariable {
	
	typealias ReferenceType = XSQLVAR
		
	let handle: UnsafeMutablePointer<ReferenceType>
	
	private var pointee: ReferenceType {
		self.handle.pointee
	}
	
	/**
	 Indicates the SQL data type of parameters or select-list items.
	 Set during isc_dsql_describe(), isc_dsql_describe_bind(), or isc_dsql_prepare().
	 */
	var type: FirebirdDataType {
		.init(rawValue: Int32(self.pointee.sqltype))
	}
	
	/**
	 Provides scale, specified as a negative number, for exact numeric data types (DECIMAL and NUMERIC).
	 Set during isc_dsql_describe(), isc_dqql_describe_bind(), or isc_dsql_prepare().
	 */
	var scale: Int16 {
		self.pointee.sqlscale
	}
	
	/**
	 Specifies the subtype for Blob data.
	 Set during isc_dsql_describe(), isc_dsql_describe_bind(), or isc_dsql_prepare().
	 */
	var subtype: FirebirdDataType {
		.init(rawValue: Int32(self.pointee.sqlsubtype))
	}
	
	/**
	 Indicates the maximum size, in bytes, of data in the sqldata field.
	 Set during isc_dsql_describe(), isc_dsql_describe_bind(), or isc_dsql_prepare().
	 */
	var maximumSize: Int16 {
		self.pointee.sqllen
	}
		
	var data: Data? {
		nil
	}
}
