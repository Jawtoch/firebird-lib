//
//  FirebirdStatementFreeOption.swift
//  
//
//  Created by Ugo Cottin on 24/03/2022.
//

import fbclient

public struct FirebirdStatementFreeOption: RawRepresentable, Equatable {
	
	/// Properly close the cursor after fetching and processing all the rows resulting from the execution of a query
	public static let close = FirebirdStatementFreeOption(FirebirdStatementFreeOption.RawValue(DSQL_close))
	
	/// Drop the statement and all cursor associated with it
	public static let drop = FirebirdStatementFreeOption(FirebirdStatementFreeOption.RawValue(DSQL_drop))
	
	public static let unprepare = FirebirdStatementFreeOption(FirebirdStatementFreeOption.RawValue(DSQL_unprepare))
	
	public typealias RawValue = UInt16
	
	public var rawValue: UInt16
	
	public init?(rawValue: RawValue) {
		self.rawValue = rawValue
	}
	
	private init(_ rawValue: RawValue) {
		self.rawValue = rawValue
	}
	
}
