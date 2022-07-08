import CFirebird

/// https://docwiki.embarcadero.com/InterBase/2020/en/Calling_isc_start_multiple()
internal struct TEB {
	
	internal let database: UnsafePointer<isc_db_handle>
	
	internal let count: CLong
	
	internal let parameters: UnsafeBufferPointer<CChar>?
	
}
