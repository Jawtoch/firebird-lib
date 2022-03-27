//
//  FirebirdDefaultAllocationPoolSource.swift
//  
//
//  Created by ugo cottin on 26/03/2022.
//

import fbclient
import Logging

public class FirebirdDefaultAllocationPoolSource: FirebirdAllocationPoolSource {
	
	public var isReleased: Bool {
		!self.allocation.isEmpty
	}
	
	var allocation: [UnsafeRawPointer]
	
	public init() {
		self.allocation = []
	}
	
	public func makeAllocation(for variable: FirebirdSQLVariable, logger: Logger) {
		logger.debug("Allocating memory for variable \(variable)")
		if variable.type.isNullable {
			variable.unsafeNilStorage = self.allocate(CShort.self, capacity: 1, logger: logger)
		}
		
		switch variable.type {
			case .text:
				variable.unsafeDataStorage = self.allocate(CChar.self, capacity: Int(variable.maximumSize), logger: logger)
			case .varying:
				variable.unsafeDataStorage = self.allocate(CChar.self, capacity: Int(variable.maximumSize) + 2, logger: logger)
			case .long, .d_float, .float:
				variable.unsafeDataStorage = self.allocate(CLong.self, capacity: 1, logger: logger)
			case .short:
				variable.unsafeDataStorage = self.allocate(CShort.self, capacity: 1, logger: logger)
			case .int64:
				variable.unsafeDataStorage = self.allocate(Int64.self, capacity: 1, logger: logger)
			case .timestamp, .time, .date:
				variable.unsafeDataStorage = self.allocate(ISC_TIMESTAMP.self, capacity: 1, logger: logger)
			default:
				logger.debug("No memory allocated for type \(variable.type)")
		}
	}
	
	private func allocate<T, R>(_ type: T.Type, capacity: Int, logger: Logger) -> UnsafeMutablePointer<R> {
		let memoryLayout = MemoryLayout<T>.self
		logger.debug("Allocating memory for \(capacity)x \(type)")
		let rawPointer = UnsafeMutableRawPointer.allocate(byteCount: memoryLayout.stride * capacity, alignment: memoryLayout.alignment)
		self.allocation.append(rawPointer)
		
		return rawPointer.assumingMemoryBound(to: R.self)
	}
	
	public func release(logger: Logger) {
		let count = self.allocation.count
		self.allocation.forEach { $0.deallocate() }
		self.allocation.removeAll()
		logger.debug("Releasing allocation pool with \(count) allocation(s)")
	}
	
}

