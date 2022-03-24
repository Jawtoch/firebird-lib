//
//  FirebirdDescriptorArea.swift
//  
//
//  Created by Ugo Cottin on 19/03/2022.
//

import fbclient

struct FirebirdDescriptorArea {
	
	typealias ReferenceType = XSQLDA
	
	static func XSQLDA_LENGTH(_ size: Int) -> Int {
		MemoryLayout<XSQLDA>.size + (size - 1) * MemoryLayout<XSQLVAR>.size
	}
	
	init(capacity count: Int16, version: Int16) {
		self.handle = .allocate(capacity: Int(count))
		self.count = count
		self.version = version
	}
	
	func deallocate() {
		self.handle.deallocate()
	}
	
	let handle: UnsafeMutablePointer<ReferenceType>
	
	var isLargeEnough: Bool {
		self.parametersCount <= self.count
	}
	
	private var pointee: ReferenceType {
		self.handle.pointee
	}
	
	/// Indicates the version of the XSQLDA structure. Set this to SQLDA_CURRENT_VERSION, which is defined in ibase.h.
	var version: ISC_SHORT {
		get {
			self.pointee.version
		}
		set {
			self.handle.pointee.version = newValue
		}
	}
	
	/// Indicates the number of elements in the sqlvar array; the application should set this field whenever it allocates storage for a descriptor.
	var count: ISC_SHORT {
		get {
			self.pointee.sqln
		}
		set {
			self.handle.pointee.sqln = newValue
		}
	}
	
	/**
	 Indicates the number of parameters for an input XSQLDA, or the number of select-list items for an output XSQLDA; set during an isc_dsql_describe(), isc_dsql_describe_bind(), or isc_dsql_prepare(). For an input descriptor, a sqld of 0 indicates that the SQL statement has no parameters; for an output descriptor, a sqld of 0 indicates that the SQL statement is not a SELECT statement.
	 */
	var parametersCount: ISC_SHORT {
		get {
			self.pointee.sqld
		}
		set {
			self.handle.pointee.sqld = newValue
		}
	}
	
	var variables: [FirebirdSQLVariable] {
		return withUnsafeMutablePointer(to: &self.handle.pointee.sqlvar) { pointer in
			var array: [FirebirdSQLVariable] = []
			for index in 0 ..< Int(Swift.min(self.count, self.parametersCount)) {
				array.append(FirebirdSQLVariable(handle: pointer.advanced(by: index)))
			}
			
			return array
		}
	}
}

extension FirebirdDescriptorArea: Sequence {
	
	func makeIterator() -> AnyIterator<FirebirdSQLVariable> {
		var index = 0
		
		return AnyIterator {
			defer { index += 1 }
			return index < self.variables.count ? self.variables[index] : nil
		}
	}
	
}
