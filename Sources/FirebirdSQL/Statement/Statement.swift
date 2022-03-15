//
//  File.swift
//  
//
//  Created by ugo cottin on 03/03/2022.
//

import Foundation

protocol Statement: AnyObject {
    
    associatedtype Database: FirebirdSQL.Database

}
