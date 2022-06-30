//
//  FirebirdBind.swift
//  
//
//  Created by Ugo Cottin on 28/06/2022.
//

import CFirebird
import Foundation

public class FirebirdBind {
	
	public typealias ReferenceType = XSQLVAR
	
	public let handle: UnsafeMutablePointer<ReferenceType>
	
	public init(handle: UnsafeMutablePointer<ReferenceType>) {
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
	
	public var subType: FirebirdDataType {
		get {
			FirebirdDataType(rawValue: self.handle.pointee.sqlsubtype)!
		}
		set {
			self.handle.pointee.sqlsubtype = ISC_SHORT(newValue.rawValue)
		}
	}
	
	public var scale: ISC_SHORT {
		get {
			self.handle.pointee.sqlscale
		}
		set {
			self.handle.pointee.sqlscale = newValue
		}
	}
	
	public var length: ISC_SHORT {
		get {
			self.handle.pointee.sqllen
		}
		set {
			self.handle.pointee.sqllen = newValue
		}
	}
	
	public var name: String {
		String(cString: &self.handle.pointee.aliasname.0)
	}
	
	public var originalName: String {
		String(cString: &self.handle.pointee.sqlname.0)
	}
	
	public var tableOwner: String {
		String(cString: &self.handle.pointee.ownname.0)
	}
	
	public var tableName: String {
		String(cString: &self.handle.pointee.relname.0)
	}
	
	public var size: Int16 {
		self.length + (self.type == .varying ? 2 : 0)
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
	
	public func getData() throws -> Data? {
		if self.type.isNullable {
			guard let unsafeNilStorage = self.unsafeNilStorage else {
				fatalError()
			}
			
			if unsafeNilStorage.pointee == -1 {
				return nil
			}
		}
		
		guard let unsafeDataStorage = self.unsafeDataStorage else {
			fatalError()
		}
		
		return Data(bytes: unsafeDataStorage, count: Int(self.size))

	}
	
	public func setData(_ data: Data?) throws {
		if let data = data {
			guard let unsafeDataStorage = self.unsafeDataStorage else {
				fatalError()
			}
			
			let dataSize = min(data.count, Int(self.size))
			unsafeDataStorage.withMemoryRebound(to: Data.Element.self, capacity: dataSize) { data.copyBytes(to: $0, count: dataSize) }
			
			if self.type.isNullable {
				guard let unsafeNilStorage = self.unsafeNilStorage else {
					fatalError()
				}

				unsafeNilStorage.pointee = -1
			}
		} else {
			guard self.type.isNullable else {
				fatalError()
			}
			
			guard let unsafeNilStorage = self.unsafeNilStorage else {
				fatalError()
			}
			
			unsafeNilStorage.pointee = -1
		}
	}
	
}
