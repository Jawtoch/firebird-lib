import CFirebird
import Foundation

public class FirebirdXSQLVariable {
	
    public enum Error: FirebirdError {
        case notAllocated
    }
    
	public typealias Handle = UnsafeMutablePointer<XSQLVAR>
	
	public let handle: Handle
	
	internal init(handle: Handle) {
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
	
	public var length: Int16 {
		get {
			self.handle.pointee.sqllen + (self.type == .varying ? 2 : 0)
		}
		set {
			self.handle.pointee.sqllen = newValue
		}
	}
	
	public var scale: Int16 {
		get {
			self.handle.pointee.sqlscale
		}
		set {
			self.handle.pointee.sqlscale = newValue
		}
	}
	
	public var name: String {
		String(cString: &self.handle.pointee.sqlname.0)
	}
	
	public var aliasName: String {
		String(cString: &self.handle.pointee.aliasname.0)
	}
	
	public var tableName: String {
		String(cString: &self.handle.pointee.relname.0)
	}
	
	public var tableOwnerName: String {
		String(cString: &self.handle.pointee.ownname.0)
	}
	
	public var dataPointer: UnsafeMutablePointer<ISC_SCHAR>? {
		get {
			self.handle.pointee.sqldata
		}
		set {
			self.handle.pointee.sqldata = newValue
		}
	}
	
	public var nilPointer: UnsafeMutablePointer<ISC_SHORT>? {
		get {
			self.handle.pointee.sqlind
		}
		set {
			self.handle.pointee.sqlind = newValue
		}
	}
		    
    public func readValue() throws -> Data? {
        if self.type.isNullable {
            guard let nilPointer else {
                throw Error.notAllocated
            }
            
            if nilPointer.pointee < 0 {
                return nil
            }
        }
        
        guard let dataPointer else {
            throw Error.notAllocated
        }
        
        return Data(bytes: dataPointer, count: Int(self.length))
    }
    
    public func write(_ value: Data?) throws {
        if self.type.isNullable {
            guard let nilPointer else {
                throw Error.notAllocated
            }
            
            nilPointer.pointee = value == nil ? -1 : 0
        }
        
        guard let dataPointer else {
            throw Error.notAllocated
        }
        
        guard let value else {
            return
        }
        
        let maxLength = min(value.count, Int(self.length))
        
        dataPointer.withMemoryRebound(to: Data.Element.self, capacity: maxLength) {
            value.copyBytes(to: $0, count: maxLength)
        }
    }
    
    public func readData() throws -> FirebirdData {
        return FirebirdData(name: self.aliasName, type: self.type, subType: self.subType, value: try self.readValue())
    }
    
    public func write(_ data: FirebirdData) throws {
        try self.write(data.value)
        
        self.type = data.type
        self.subType = data.subType
    }
	
}
