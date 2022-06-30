//
//  FBAllocationPool.swift
//
//
//  Created by ugo cottin on 25/06/2022.
//

import CFirebird

class FBAllocationPool: FirebirdAllocationPool {
	
	var allocations: [UnsafeMutableRawPointer]
	
	init() {
		self.allocations = []
	}
	
	func allocate(bind: FirebirdBind) {
		let allocation: UnsafeMutablePointer<ISC_SCHAR>
		switch bind.type {
			case .text:
				allocation = self.makeAllocation(for: CChar.self, capacity: Int(bind.length))
			case .varying:
				allocation = self.makeAllocation(for: CChar.self, capacity: Int(bind.size))
			default:
				allocation = UnsafeMutableRawPointer.allocate(byteCount: 1024, alignment: 8)
					.assumingMemoryBound(to: ISC_SCHAR.self)
		}
		
		self.allocations.append(allocation)
		bind.unsafeDataStorage = allocation
		
		if bind.type.isNullable {
			let nilStorage = self.makeAllocation(for: ISC_SHORT.self, capacity: 1, as: ISC_SHORT.self)
			self.allocations.append(nilStorage)
			bind.unsafeNilStorage = nilStorage
		}
	}
	
	private func makeAllocation<T>(for type: T.Type, capacity: Int) -> UnsafeMutablePointer<ISC_SCHAR> {
		self.makeAllocation(for: type, capacity: capacity, as: ISC_SCHAR.self)
	}
	
	private func makeAllocation<T, R>(for type: T.Type, capacity: Int, as: R.Type) -> UnsafeMutablePointer<R> {
		let memoryLayout = MemoryLayout<T>.self
		let rawPointer = UnsafeMutableRawPointer
			.allocate(byteCount: memoryLayout.stride * capacity, alignment: memoryLayout.alignment)
		
		return rawPointer
			.assumingMemoryBound(to: R.self)
	}
	
	func release() {
		self.allocations.forEach { allocation in
			allocation.deallocate()
		}
		
		self.allocations.removeAll()
	}
	
}
