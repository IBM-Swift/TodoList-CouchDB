/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

import LoggerAPI
import TodoListAPI
import SwiftyJSON

import CouchDB


#if os(Linux)
    typealias Valuetype = Any
#else
    typealias Valuetype = AnyObject
#endif

/// TodoList for Redis
public class TodoList: TodoListAPI {
    
    static let DefaultCouchHost = "127.0.0.1"
    static let DefaultCouchPort = UInt16(5984)
    
    let databaseName: String
    
    let connectionProperties: ConnectionProperties
    
    public init(database: String, host: String = TodoList.DefaultCouchHost, port: UInt16 = TodoList.DefaultCouchPort,
                username: String?, password: String?) {
        
        
        connectionProperties = ConnectionProperties(host: host, port: Int16(port), secured: true,
                                                    username: username, password: password)
        
        self.databaseName = database
        
    }
    
    public var count: Int {
        return 0
    }
    
    public func clear(_ oncompletion: (Void) -> Void) {
        
    }
    
    public func getAll(_ oncompletion: ([TodoItem]) -> Void ) throws {
        
    }
    
    public func get(_ id: String, oncompletion: (TodoItem?) -> Void ) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)

        database.retrieve(id) {
            document, error in
            
            
        }
        
    }
    
    public func add(title: String, order: Int = 0, completed: Bool = false, oncompletion: (TodoItem) -> Void ) throws {
        
        let json: [String: Valuetype] = [
                                            "title": title,
                                            "order": order,
                                            "completed": completed
                                            ]
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        
        database.create(JSON(json)) {
            id, rev, document, error in
            
           

            
        }
        
        
    }
    
    public func update(id: String, title: String?, order: Int?, completed: Bool?, oncompletion: (TodoItem?) -> Void ) {
        
    }
    
    public func delete(_ id: String, oncompletion: (Void) -> Void) {
        
        
    }
    
    
}