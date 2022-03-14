//
//  FirebirdStatement.swift
//  
//
//  Created by Ugo Cottin on 14/03/2022.
//

import fbclient


class FirebirdStatement: Statement {
    
    var handle: isc_stmt_handle
    
    var status: [ISC_STATUS]
    
    init() {
        self.handle = 0
        self.status = FirebirdError.statusArray
    }
    
    func close() {
        
    }
    
    func closeCursor() {
        
    }
    
    func unprepare() {
        
    }
    
    
    typealias Database = FirebirdDatabase
    
    
}
