//
//  File.swift
//  
//
//  Created by ugo cottin on 03/03/2022.
//

import Foundation

protocol Statement {
    
    associatedtype Database: FirebirdSQL.Database
    
    func close()
    
    func closeCursor()
    
    func unprepare()
    
    
}
