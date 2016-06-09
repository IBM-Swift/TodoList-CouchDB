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
    
    let databaseName: String = "todolist"
    
    let connectionProperties: ConnectionProperties
    
    public init(_ dbConfiguration: DatabaseConfiguration) {
        
        connectionProperties = ConnectionProperties(host: dbConfiguration.host!,
                                                    port: Int16(dbConfiguration.port!),
                                                    secured: true,
                                                    username: dbConfiguration.username,
                                                    password: dbConfiguration.password)
        
    }
    
    public init(database: String = "todolist", host: String = TodoList.DefaultCouchHost,
                port: UInt16 = TodoList.DefaultCouchPort,
                username: String? = nil, password: String? = nil) {
        
        
        connectionProperties = ConnectionProperties(host: host, port: Int16(port), secured: false,
                                                    username: username, password: password)
        
    }
    
    public func count( _ oncompletion: (Int) -> Void) throws {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.queryByView("total_todos", ofDesign: "example", usingParameters: []) {
                document, error in
            
            if let document = document where error == nil {
                
                if let numberOfTodos = document["rows"][0]["value"].int {
                    oncompletion( numberOfTodos )
                } else {
                    oncompletion( 0 )
                }
                
                
            }
            
        }
    }
    
    public func clear(_ oncompletion: (Void) -> Void) throws {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.queryByView("all_todos", ofDesign: "example",
                             usingParameters: [.descending(true), .includeDocs(true)])
        { document, error in
            
            guard let document = document else {
                return
            }
            
            
            guard let idRevs = try? parseGetIDandRev(document) else {
                return
            }
            
            let count = idRevs.count
            
            if count == 0 {
                oncompletion()
            } else {
                var numberCompleted = 0
                
                for i in 0...count-1 {
                    let item = idRevs[i]
                    
                    database.delete(item.0, rev: item.1) {
                        error in
                        
                        if error != nil {
                            return
                        }
                        
                        numberCompleted += 1
                        
                        if numberCompleted == count {
                            oncompletion()
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    public func getAll(_ oncompletion: ([TodoItem]) -> Void ) throws {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.queryByView("all_todos", ofDesign: "example",
                             usingParameters: [.descending(true), .includeDocs(true)]) {
            document, error in
            
            if let document = document where error == nil {
        
                do {
                    let todoItems = try parseTodoItemList(document)
                    oncompletion(todoItems)
                } catch {
                    
                }
                
            }
            
            
        }
        
    }
    
    public func get(_ id: String, oncompletion: (TodoItem?) -> Void ) throws {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.retrieve(id) {
            document, error in
            
            
            
            if let document = document {
                
                let id = document["_id"].string
                let title = document["title"].string
                let order = document["order"].int
                let completed = document["completed"].bool
                
                guard let sid = id else {
                    return
                }
                
                guard let stitle = title else {
                    return
                }
                
                guard let sorder = order else {
                    return
                }
                
                guard let scompleted = completed else {
                    return
                }
                
                let todoItem = TodoItem(id: sid, order: sorder, title: stitle, completed: scompleted)
                
                oncompletion(todoItem)
                
            }
            
            
        }
        
    }
    
    public func add(title: String, order: Int = 0, completed: Bool = false, oncompletion: (TodoItem) -> Void ) throws {
        
        let json: [String: Valuetype] = [
                                            "active": true,
                                            "type": "todo",
                                            "title": title,
                                            "order": order,
                                            "completed": completed
        ]
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        
        database.create(JSON(json)) {
            id, rev, document, error in
            
            if let id = id {
                let todoItem = TodoItem(id: id, order: order, title: title, completed: completed)
                
                oncompletion( todoItem )
            }
            
        }
        
        
    }
    
    public func update(id: String, title: String?, order: Int?, completed: Bool?, oncompletion: (TodoItem?) -> Void ) throws {
        
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.retrieve(id) {
            document, error in
            
            if let document = document {
                
                let rev = document["_rev"].string!
                
                let json: [String: Valuetype] = [
                                                    "title": title != nil ? title! : document["title"].string!,
                                                    "order": order != nil ? order! : document["order"].int!,
                                                    "completed": completed != nil ? completed! : document["completed"].bool!
                                                ]
                
                database.update(id, rev: rev, document: JSON(json)) {
                    rev, document, error in
                    
                    do {
                        try self.get(id) {
                            document in
                        
                            if let document = document {
                            
                                oncompletion(document)
                            
                            }
                        }
                    } catch {
                        Log.error("Could not get document")
                    }
                }
            }
        }
        
    }
    
    public func delete(_ id: String, oncompletion: (Void) -> Void) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.retrieve(id) {
            document, error in
            
            if let document = document {
                
                let rev = document["_rev"].string!
                
                database.delete( id, rev: rev) {
                    error in
                    
                    oncompletion()
                }

                
            }
        }
        
        
    }
    
    
}


func parseGetIDandRev(_ document: JSON) throws -> [(String, String)] {
    guard let rows = document["rows"].array else {
        throw TodoCollectionError.parseError
    }
    
    return rows.flatMap {
        
        let doc = $0["doc"]
        let id = doc["_id"].string!
        let rev = doc["_rev"].string!
    
        return (id, rev)
        
    }

}

func parseTodoItemList(_ document: JSON) throws -> [TodoItem] {
    guard let rows = document["rows"].array else {
        throw TodoCollectionError.parseError
    }
    
    let todos: [TodoItem] = rows.flatMap {
        
        let doc = $0["value"]
        let id = $0["id"].string
        let title = doc[0].string
        let order = doc[2].int
        let completed = doc[1].bool
 
        return TodoItem(id: id!, order: order!, title: title!, completed: completed!)
       
    }
    
    return todos
}