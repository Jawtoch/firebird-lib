public protocol Factory {
	
	associatedtype Produced
	
	func next() -> Produced
	
}
