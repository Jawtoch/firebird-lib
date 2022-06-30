//
//  FirebirdBindings.swift
//  
//
//  Created by Ugo Cottin on 28/06/2022.
//

import CFirebird

public class FirebirdBindings {
	
	public struct Version: RawRepresentable {
		
		public typealias RawValue = ISC_SHORT
		
		public static let current = Self(rawValue: Self.RawValue(SQLDA_VERSION1))
		
		public static let version1 = Self(rawValue: Self.RawValue(SQLDA_VERSION1))
		
		public var rawValue: RawValue
		
		public init(rawValue: RawValue) {
			self.rawValue = rawValue
		}
		
	}
	
	public typealias ReferenceType = XSQLDA
	
	public static func XSQLDA_LENGTH(_ numberOfFields: Int16) -> Int {
		return MemoryLayout<ReferenceType>.size + Int(numberOfFields - 1) * MemoryLayout<FirebirdBind.ReferenceType>.size
	}
	
	public init(numberOfFields: Int16, version: Version) {
		self.handle = UnsafeMutableRawPointer
			.allocate(byteCount: Self.XSQLDA_LENGTH(numberOfFields), alignment: 1)
			.assumingMemoryBound(to: Self.ReferenceType.self)
		
		self.numberOfAllocatedFields = numberOfFields
		self.version = version
	}
	
	deinit {
		self.handle.deallocate()
	}
	
	internal let handle: UnsafeMutablePointer<ReferenceType>
	
	public var version: Version {
		get {
			Self.Version(rawValue: self.handle.pointee.version)
		}
		set {
			self.handle.pointee.version = newValue.rawValue
		}
	}
	
	public var numberOfAllocatedFields: Int16 {
		get {
			self.handle.pointee.sqln
		}
		set {
			self.handle.pointee.sqln = newValue
		}
	}
	
	public var numberOfFields: Int16 {
		self.handle.pointee.sqld
	}
	
	public var binds: [FirebirdBind] {
		let range = (0 ..< min(self.numberOfFields, self.numberOfAllocatedFields))
		return withUnsafeMutablePointer(to: &self.handle.pointee.sqlvar) { unsafeVar in
			range.map { unsafeVar.advanced(by: Int($0)) }.map { FirebirdBind(handle: $0) }
		}
	}
	
}
