//
//  FirebirdSQLVariable.swift
//  
//
//  Created by Ugo Cottin on 19/03/2022.
//

import fbclient
import Foundation

public class FirebirdSQLVariable {
	
	public typealias ReferenceType = XSQLVAR
		
	public let handle: UnsafeMutablePointer<ReferenceType>
	
	public init(handle: UnsafeMutablePointer<ReferenceType>) {
		self.handle = handle
	}
	
	private var pointee: ReferenceType {
		self.handle.pointee
	}
	
	/**
	 Indicates the SQL data type of parameters or select-list items.
	 Set during isc_dsql_describe(), isc_dsql_describe_bind(), or isc_dsql_prepare().
	 */
	public var type: FirebirdDataType {
		.init(rawValue: Int32(self.pointee.sqltype))
	}
	
	/**
	 Provides scale, specified as a negative number, for exact numeric data types (DECIMAL and NUMERIC).
	 Set during isc_dsql_describe(), isc_dqql_describe_bind(), or isc_dsql_prepare().
	 */
	public var scale: Int16 {
		self.pointee.sqlscale
	}
	
	/**
	 Specifies the subtype for Blob data.
	 Set during isc_dsql_describe(), isc_dsql_describe_bind(), or isc_dsql_prepare().
	 */
	public var subtype: FirebirdDataType {
		.init(rawValue: Int32(self.pointee.sqlsubtype))
	}
	
	/**
	 Indicates the maximum size, in bytes, of data in the sqldata field.
	 Set during isc_dsql_describe(), isc_dsql_describe_bind(), or isc_dsql_prepare().
	 */
	public var maximumSize: Int16 {
		self.pointee.sqllen
	}
		
	public var data: Data? {
		Data(bytes: self.handle.pointee.sqldata, count: Int(self.maximumSize))
	}
	
	public var name: String {
		String(cString: &self.handle.pointee.sqlname.0)
	}
	
	public var relation: String {
		String(cString: &self.handle.pointee.relname.0)
	}
	
	public var owner: String {
		String(cString: &self.handle.pointee.ownname.0)
	}
	
	public var alias: String {
		String(cString: &self.handle.pointee.aliasname.0)
	}
		
	public var unsafeDataStorage: UnsafeMutablePointer<ISC_SCHAR>? {
		get {
			self.handle.pointee.sqldata
		}
		set {
			self.handle.pointee.sqldata = newValue
		}
	}
	
	public var unsafeNilStorage: UnsafeMutablePointer<ISC_SHORT>? {
		get {
			self.handle.pointee.sqlind
		}
		set {
			self.handle.pointee.sqlind = newValue
		}
	}
}

extension FirebirdSQLVariable: CustomStringConvertible {
	
	public var description: String {
		"\(self.name)"
	}
	
}
