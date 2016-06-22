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
    
    let databaseName = "todolist"
    
    let designName = "tododb"
    
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
    
    public func count(oncompletion: (Int, ErrorProtocol?) -> Void) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.queryByView("total_todos", ofDesign: designName, usingParameters: []) {
            document, error in
            
            if let document = document where error == nil {
                
                if let numberOfTodos = document["rows"][0]["value"].int {
                    oncompletion( numberOfTodos , nil)
                } else {
                    oncompletion( 0 , nil)
                }
                
                
            }
            
        }
    }
    
    public func count(withUser: String, oncompletion: (Int, ErrorProtocol?) -> Void) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.queryByView("user_todos", ofDesign: designName, usingParameters: [.keys([withUser])]) {
            document, error in
            
            if let document = document where error == nil {
                
                if let numberOfTodos = document["rows"][0]["value"].int {
                    oncompletion( numberOfTodos , nil)
                } else {
                    oncompletion( 0 , nil)
                }
                
                
            }
            
        }
    }
    
    
    public func clear(oncompletion: (ErrorProtocol?) -> Void) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.queryByView("all_todos", ofDesign: designName,
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
                oncompletion( nil )
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
                            oncompletion( nil )
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    public func clear(withUser: String, oncompletion: (ErrorProtocol?) -> Void) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.queryByView("user_todos", ofDesign: designName,
                             usingParameters: [.descending(true), .includeDocs(true), .keys([withUser])])
        { document, error in
            
            guard let document = document else {
                return
            }
            
            
            guard let idRevs = try? parseGetIDandRev(document) else {
                return
            }
            
            let count = idRevs.count
            
            if count == 0 {
                oncompletion( nil )
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
                            oncompletion( nil )
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    
    
    public func get(oncompletion: ([TodoItem], ErrorProtocol?) -> Void ) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.queryByView("total_todos", ofDesign: designName,
                             usingParameters: [.descending(true), .includeDocs(true)]) {
                                document, error in
                                
                                if let document = document where error == nil {
                                    
                                    do {
                                        let todoItems = try parseTodoItemList(document)
                                        oncompletion(todoItems, nil)
                                    } catch {
                                        
                                    }
                                    
                                }
                                
                                
        }
        
    }
    
    public func get(withUser: String, oncompletion: ([TodoItem], ErrorProtocol?) -> Void ) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.queryByView("user_todos", ofDesign: designName,
                             usingParameters: [.descending(true), .includeDocs(true), .keys([withUser])]) {
                                document, error in
                                
                                if let document = document where error == nil {
                                    
                                    do {
                                        let todoItems = try parseTodoItemList(document)
                                        oncompletion(todoItems, nil)
                                    } catch {
                                        
                                    }
                                    
                                }
                                else{
                                    oncompletion([], error)
                                }
                                
                                
        }
        
    }
    
    public func get(withUser: String, withId: String, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.retrieve(withId) {
            document, error in
            
            
            if let document = document {
                let id = document["_id"].string
                let user = document["user"].string
                let title = document["title"].string
                let order = document["order"].int
                let completed = document["completed"].bool
                
                if withUser == user {
                    guard let sid = id else {
                        return
                    }
                    
                    guard let suser = user else {
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
                    
                    let todoItem = TodoItem(id: sid, user: suser, order: sorder, title: stitle, completed: scompleted)
                    
                    oncompletion(todoItem, nil)
                }
                else{
                    oncompletion(nil, TodoCollectionError.authError)
                }
                
            }
            
            
            
        }
        
    }
    
    public func add(user: String, title: String, order: Int = 0, completed: Bool = false, oncompletion: (TodoItem, ErrorProtocol?) -> Void ) {
        
        let json: [String: Valuetype] = [
                                            "type": "todo",
                                            "user": user,
                                            "title": title,
                                            "order": order,
                                            "completed": completed
        ]
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        
        database.create(JSON(json)) {
            id, rev, document, error in
            
            if let id = id {
                let todoItem = TodoItem(id: id, user: user, order: order, title: title, completed: completed)
                
                oncompletion( todoItem , nil)
            }
            
        }
        
        
    }
    
    public func update(id: String, user: String?, title: String?, order: Int?, completed: Bool?, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.retrieve(id) {
            document, error in
            
            if let document = document {
                
                let rev = document["_rev"].string!
                
                let json: [String: Valuetype] = [
                                                    "type": "todo",
                                                    "user": user != nil ? user! : document["user"].string!,
                                                    "title": title != nil ? title! : document["title"].string!,
                                                    "order": order != nil ? order! : document["order"].int!,
                                                    "completed": completed != nil ? completed! : document["completed"].bool!
                ]
                
                database.update(id, rev: rev, document: JSON(json)) {
                    rev, document, error in
                    
                    if error != nil {
                        
                        oncompletion(nil, error)
                    }
                    
                    /*do {
                     try self.get(id) {
                     document in
                     
                     if let document = document {
                     
                     oncompletion(document)
                     
                     }
                     }
                     } catch {
                     Log.error("Could not get document")
                     }*/
                    
                    /*self.get(id){
                     document in
                     
                     if let document = document{
                     oncompletion(document)
                     }
                     else{
                     Log.error("Could not get document")
                     }
                     }*/
                }
            }
        }
        
    }
    
    public func delete(withUser: String, withId id: String, oncompletion: (ErrorProtocol?) -> Void) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.retrieve(id) {
            document, error in
            
            if let document = document {
                
                let rev = document["_rev"].string!
                let user = document["user"].string!
                
                if withUser == user{
                    database.delete( id, rev: rev) {
                        error in
                        
                        oncompletion(nil)
                    }
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
        
        let id = doc[0].string
        let user = doc[1].string
        let title = doc[2].string
        let completed = doc[3].bool
        let order = doc[4].int
        
        
        return TodoItem(id: id!, user: user!, order: order!, title: title!, completed: completed!)
        
    }
    
    return todos
}