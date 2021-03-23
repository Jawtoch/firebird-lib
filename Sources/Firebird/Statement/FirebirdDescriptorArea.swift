//
//  FirebirdDescriptorArea.swift
//  
//
//  Created by Ugo Cottin on 23/03/2021.
//

public class FirebirdDescriptorArea {
	
	/// Return the required size for storing `size` columns descriptors
	/// - Parameter size: number of columns descriptors needed
	/// - Returns: the memory space for storing the descriptors
	public static func XSQLDA_LENGTH(_ size: Int) -> Int {
		MemoryLayout<XSQLDA>.size + (size - 1) * MemoryLayout<XSQLVAR>.size
	}
	
	public var handle: XSQLDA
	
	public init() {
		self.handle = XSQLDA()
	}
	
}
