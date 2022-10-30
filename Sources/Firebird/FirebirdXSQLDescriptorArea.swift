import CFirebird
import Foundation

func XSQLDA_LENGTH(capacity: Int) -> Int {
	MemoryLayout<XSQLDA>.size + (capacity - 1) * MemoryLayout<XSQLVAR>.size
}

public class FirebirdXSQLDescriptorArea {
	
	public struct Version: RawRepresentable {
		
		public typealias RawValue = ISC_SHORT
				
		public static let version1 = Self(rawValue: Self.RawValue(SQLDA_VERSION1))
		
		public let rawValue: RawValue
		
		public init(rawValue: RawValue) {
			self.rawValue = rawValue
		}
		
	}
	
	public typealias Handle = UnsafeMutablePointer<XSQLDA>
	
	public var handle: Handle
	
	public init(version: Version, initialCapacity: Int16) {
		self.handle = UnsafeMutableRawPointer
			.allocate(byteCount: XSQLDA_LENGTH(capacity: Int(initialCapacity)), alignment: 1)
			.assumingMemoryBound(to: XSQLDA.self)
		
		self.version = version
		self.capacity = initialCapacity
	}
	
	deinit {
		self.handle.deallocate()
	}
	
	public var version: Version {
		get {
			Version(rawValue: self.handle.pointee.version)
		}
		set {
			self.handle.pointee.version = newValue.rawValue
		}
	}
	
	public var capacity: Int16 {
		get {
			self.handle.pointee.sqln
		}
		set {
			self.handle.pointee.sqln = newValue
		}
	}
	
	public var requiredCapacity: Int16 {
		self.handle.pointee.sqld
	}
	
	public var count: Int16 {
		Swift.min(self.capacity, self.requiredCapacity)
	}
		
	public func variable(at index: Int) -> FirebirdXSQLVariable {
		withUnsafeMutablePointer(to: &self.handle.pointee.sqlvar) {
			FirebirdXSQLVariable(handle: $0.advanced(by: index))
		}
	}
	
	public subscript(index: Int) -> FirebirdXSQLVariable {
		self.variable(at: index)
	}
    
    public func write(_ datas: [FirebirdData]) throws {
        for (index, data) in datas.enumerated() {
            try self.write(data, atIndex: index)
        }
    }
    
    public func write(_ data: FirebirdData, atIndex index: Int) throws {
        try self.variable(at: index)
            .write(data)
    }
	
}

extension FirebirdXSQLDescriptorArea: Sequence {
	
	public func makeIterator() -> AnyIterator<FirebirdXSQLVariable> {
		var index = 0
		let endIndex = Int(self.count)
		
		return AnyIterator {
			if index < endIndex {
				let variable = self.variable(at: index)
				index += 1
				
				return variable
			}
			
			return nil
		}
	}
	
}
