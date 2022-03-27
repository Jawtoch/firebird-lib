//
//  Utils.swift
//  
//
//  Created by ugo cottin on 27/03/2022.
//

import fbclient

func withStatus(_ closure: (inout [ISC_STATUS]) throws -> ISC_STATUS) throws {
	var status = FirebirdVectorError.vector
	if try closure(&status) > 0 {
		throw FirebirdVectorError(from: status)
	}
}
