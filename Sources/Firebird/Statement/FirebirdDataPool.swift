//
//  FirebirdDataPool.swift
//  
//
//  Created by Ugo Cottin on 24/03/2021.
//

public class FirebirdStoragePool {
	
	public let logger: Logger
	
	private var allocatedStorage: [UnsafeRawPointer]
	
	public init(_ logger: Logger) {
		self.logger = logger
		self.allocatedStorage = []
	}
	
	deinit {
		self.release()
	}
	
	public func allocate(_ variable: DescriptorVariable) {
		if variable.nullable {
			variable.nullIndicatorPointer = self.allocateMemory(for: CShort.self, as: ISC_SHORT.self)
			self.allocatedStorage.append(UnsafeRawPointer(variable.nullIndicatorPointer))
		}
		
		switch variable.type {
			case .text:
				variable.dataPointer = self.allocateMemory(for: CChar.self, capacity: variable.size, as: ISC_SCHAR.self)
			case .varying:
				variable.dataPointer = self.allocateMemory(for: CChar.self, capacity: variable.size + 2, as: ISC_SCHAR.self)
				//variable.type = .text
			case .long, .d_float, .float:
				variable.dataPointer = self.allocateMemory(for: CLong.self, as: ISC_SCHAR.self)
			case .short:
				variable.dataPointer = self.allocateMemory(for: CShort.self, as: ISC_SCHAR.self)
			case .int64:
				variable.dataPointer = self.allocateMemory(for: Int64.self, as: ISC_SCHAR.self)
			case .timestamp, .time, .date:
				variable.dataPointer = self.allocateMemory(for: ISC_TIMESTAMP.self, as: ISC_SCHAR.self)
			default:
				fatalError("datatype unsupported: \(variable.type)")
		}
		
		self.allocatedStorage.append(UnsafeRawPointer(variable.dataPointer))
	}
	
	func release() {
		let count = self.allocatedStorage.count
		self.allocatedStorage.forEach { $0.deallocate() }
		self.allocatedStorage.removeAll()
		self.logger.trace("Pool release \(count) allocated storages")
	}

	private func allocateMemory<T, S>(for type: T.Type, capacity: Int = 1, as: S.Type) -> UnsafeMutablePointer<S> {
		self.logger.trace("Allocating storage for \(type) x\(capacity)")
		return UnsafeMutableRawPointer
			.allocate(byteCount: MemoryLayout<T>.stride * capacity, alignment: MemoryLayout<T>.alignment)
			.assumingMemoryBound(to: S.self)
	}
}
