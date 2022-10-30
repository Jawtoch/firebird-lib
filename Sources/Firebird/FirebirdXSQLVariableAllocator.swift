import CFirebird

public class FirebirdXSQLVariableAllocator {
	
	public var pointers: [UnsafeRawPointer]
	
	public init() {
		self.pointers = []
	}
	
	public func release() {
		for pointer in pointers {
			pointer.deallocate()
		}
		
		self.pointers.removeAll()
	}
	
	public func allocate(_ variable: FirebirdXSQLVariable) {
		if variable.type.isNullable {
			variable.nilPointer = self.allocateNilStorage()
		}
		
		variable.dataPointer = self.allocateDataStorage(forVariable: variable)
	}
	
	public func allocateNilStorage() -> UnsafeMutablePointer<ISC_SHORT> {
		self.allocateMemory(forType: ISC_SHORT.self, capacity: 1)
			.assumingMemoryBound(to: ISC_SHORT.self)
	}
	
	public func allocateDataStorage(forVariable variable: FirebirdXSQLVariable) -> UnsafeMutablePointer<ISC_SCHAR> {
		self.allocateDataStorage(forVariable: variable)
			.assumingMemoryBound(to: ISC_SCHAR.self)
	}
	
	public func allocateDataStorage(forVariable variable: FirebirdXSQLVariable) -> UnsafeMutableRawPointer {
        return self.allocateMemory(forType: ISC_SCHAR.self, capacity: Int(variable.length))
	}
	
	public func allocateMemory<T>(forType: T.Type, capacity: Int) -> UnsafeMutableRawPointer {
		let memoryLayout = MemoryLayout<T>.self
		let rawPointer = UnsafeMutableRawPointer
			.allocate(byteCount: memoryLayout.stride * capacity, alignment: memoryLayout.alignment)
		
		self.pointers.append(rawPointer)
		return rawPointer
	}
	
}
