//
//  CouchDBExtensions.swift
//  TodoList
//
//  Created by Robert F. Dickerson on 9/27/16.
//
//

import Foundation
import MiniPromiseKit
import CouchDB

extension CouchDBClient {
    
    func dbExists(_ dbName: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            dbExists(dbName) { (result, error) in
                if error != nil {
                    reject(error!)
                } else {
                    fulfill(result)
                }
                
                
            }
        }
    }
    
        
}
