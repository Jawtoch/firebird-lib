import CFirebird

public protocol FirebirdStatement {
	
	func prepare()
	
	func run()
	
	func close()
	
}
