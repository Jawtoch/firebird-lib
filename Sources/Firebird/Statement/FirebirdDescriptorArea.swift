//
//  FirebirdDescriptorArea.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

import Foundation

public class FirebirdDescriptorArea {
	
	/// Return the required size for storing `size` columns descriptors
	/// - Parameter size: number of columns descriptors needed
	/// - Returns: the memory space for storing the descriptors
	public static func XSQLDA_LENGTH(_ size: Int) -> Int {
		MemoryLayout<XSQLDA>.size + (size - 1) * MemoryLayout<XSQLVAR>.size
	}
	
	public let handle: UnsafeMutablePointer<XSQLDA>
	
	public init(from handle: UnsafeMutablePointer<XSQLDA>) {
		self.handle = handle
	}
	
	/// Indicate the version of the descriptor structure (see "XSQLDA structure version")
	public var version: Int16 {
		get {
			self.handle.pointee.version
		}
		set {
			self.handle.pointee.version = newValue
		}
	}
	
	/// Number of variables descriptor contained in the area
	public var count: Int16 {
		get {
			self.handle.pointee.sqln
		}
		set {
			self.handle.pointee.sqln = newValue
		}
	}
	
	/// Required variables descriptor for the described statement
	public var requiredCount: Int16 {
		self.handle.pointee.sqld
	}
	
	public var variables: [DescriptorVariable] {
		return withUnsafeMutablePointer(to: &self.handle.pointee.sqlvar) { pointer in
			var array: [DescriptorVariable] = []
			for index in 0 ..< Int(min(self.count, self.requiredCount)) {
				array.append(DescriptorVariable(from: pointer.advanced(by: index)))
			}
			
			return array
		}
	}
	
	public subscript(index: Int) -> DescriptorVariable {
		get {
			self.variables[index]
		}
		set {
			withUnsafeMutablePointer(to: &self.handle.pointee.sqlvar) { pointer in
				pointer.advanced(by: index).pointee = newValue.handle.pointee
			}
		}
	}
}

public class DescriptorVariable: CustomStringConvertible {
	
	fileprivate let handle: UnsafeMutablePointer<XSQLVAR>
	
	fileprivate init(from handle: UnsafeMutablePointer<XSQLVAR>) {
		self.handle = handle
	}
	
	public var type: FirebirdDataType {
		get {
			FirebirdDataType(rawValue: self.handle.pointee.sqltype)!
		}
		set {
			self.handle.pointee.sqltype = ISC_SHORT(newValue.rawValue)
		}
		
	}
	
	public var scale: Int16 {
		self.handle.pointee.sqlscale
	}
	
	public var subtype: Int16 {
		self.handle.pointee.sqlsubtype
	}
	
	public var size: Int {
		Int(self.handle.pointee.sqllen)
	}
	
	public var nullable: Bool {
		(self.handle.pointee.sqltype & 1) != 0
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
	
	public var nullIndicatorPointer: UnsafeMutablePointer<ISC_SHORT> {
		get {
			self.handle.pointee.sqlind
		}
		set {
			self.handle.pointee.sqlind = newValue
		}
	}
	
	public var dataPointer: UnsafeMutablePointer<ISC_SCHAR> {
		get {
			self.handle.pointee.sqldata
		}
		set {
			self.handle.pointee.sqldata = newValue
		}
	}
	
	public var data: Data? {
		get {
			if self.nullable && self.handle.pointee.sqlind.pointee < 0 {
				return nil
			}
			return Data(bytes: self.handle.pointee.sqldata, count: Int(self.size))
		}
		set {
			if let newValue = newValue {
				guard let dataPointer = self.handle.pointee.sqldata else {
					debugPrint("Warning: no data pointer")
					return
				}
				
				dataPointer.withMemoryRebound(to: UInt8.self, capacity: Int(self.size)) { buffer in
					newValue.copyBytes(to: buffer, count: min(newValue.count, Int(self.size)))
				}
			} else {
				self.handle.pointee.sqlind.pointee = -1
			}
		}
	}
	
	public var description: String {
		"\(self.name) [\(self.type) \(self.size) ± \(self.scale)]"
	}
}
