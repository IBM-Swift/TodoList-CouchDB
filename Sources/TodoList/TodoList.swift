/**
 * Copyright IBM Corporation 2017
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
import SwiftyJSON
import MiniPromiseKit
import Dispatch

import CouchDB

#if os(Linux)
    typealias Valuetype = Any
#else
    typealias Valuetype = AnyObject
#endif

enum TodoListError: LocalizedError {
    case databaseAlreadyExists
}

enum Result<T> {
    case success(T)
    case error(Error)
}

/// TodoList for CouchDB
public class TodoList: TodoListAPI {
    
    static let defaultCouchHost = "127.0.0.1"
    static let defaultCouchPort = UInt16(5984)
    static let defaultDatabaseName = "todolist"
    
    let databaseName = "todolist"
    let designName = "todosdesign"
    let connectionProperties: ConnectionProperties
    let queue = DispatchQueue(label: "com.ibm.todolist", qos: .userInitiated, attributes: .concurrent)
	
    public init(_ dbConfiguration: DatabaseConfiguration) {
        connectionProperties = ConnectionProperties(host: dbConfiguration.host!,
                                                    port: Int16(dbConfiguration.port!),
                                                    secured: true,
                                                    username: dbConfiguration.username,
                                                    password: dbConfiguration.password)
		setupDB()
    }
    
    public init(database: String = TodoList.defaultDatabaseName,
                host: String = TodoList.defaultCouchHost,
                port: UInt16 = TodoList.defaultCouchPort,
                username: String? = nil, password: String? = nil) {
        
        let secured = (host == TodoList.defaultCouchHost) ? false : true
        connectionProperties = ConnectionProperties(host: host, port: Int16(port), secured: secured,
                                                    username: username, password: password)
		setupDB()
    }
    
    public func count(withUserID: String? = nil, oncompletion: @escaping (Int?, Error?) -> Void) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        let userParameter = withUserID ?? "default"
        
        database.queryByView("user_todos", ofDesign: designName,
                             usingParameters: [.keys([userParameter as Valuetype])]) {
            document, error in
            
            if let document = document , error == nil {
                if let numberOfTodos = document["rows"][0]["value"].int {
                    oncompletion(numberOfTodos, nil)
                } else {
                    oncompletion(0, nil)
                }
            } else {
                oncompletion(nil, error)
            }
        }
    }
    
    public func clear(withUserID: String? = nil, oncompletion: @escaping (Error?) -> Void) {
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        let userParameter = withUserID ?? "default"
        
        database.queryByView("user_todos", ofDesign: designName, usingParameters: [
            .descending(true), .includeDocs(true),
            .keys([userParameter as Valuetype])]) {
                document, error in
                
                guard let document = document else {
                    oncompletion(error)
                    return
                }
                guard let idRevs = try? parseGetIDandRev(document) else {
                    oncompletion(error)
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
                                oncompletion(error)
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
    
    public func clearAll(oncompletion: @escaping (Error?) -> Void) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        database.queryByView("all_todos", ofDesign: designName,
                             usingParameters: [.descending(true), .includeDocs(true)]) {
            document, error in
            
            guard let document = document else {
                oncompletion(error)
                return
            }
            
            guard let idRevs = try? parseGetIDandRev(document) else {
                oncompletion(error)
                return
            }
            
            let count = idRevs.count
            if count == 0 {
                oncompletion(nil)
            } else {
                var numberCompleted = 0
                
                for i in 0...count-1 {
                    let item = idRevs[i]
                    
                    database.delete(item.0, rev: item.1) {
                        error in
                        
                        if error != nil {
                            oncompletion(error)
                            return
                        }
                        
                        numberCompleted += 1
                        
                        if numberCompleted == count {
                            oncompletion(nil)
                        } 
                    }
                }
            }
        }
    }
    
    public func get(withUserID: String?, oncompletion: @escaping ([TodoItem]?, Error?) -> Void ) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        let userParameter = withUserID ?? "default"
        
        database.queryByView("user_todos", ofDesign: designName,
                             usingParameters: [.descending(true), .includeDocs(true),
                                               .keys([userParameter as Valuetype])]) {
                                                document, error in
                                                
                                                if let document = document , error == nil {
                                                    
                                                    do {
                                                        let todoItems = try parseTodoItemList(document)
                                                        oncompletion(todoItems, nil)
                                                    } catch {
                                                        oncompletion(nil, error)
                                                        
                                                    }
                                                    
                                                } else {
                                                    oncompletion(nil, error)
                                                }
                                                
                                                
        }
        
    }
    
    public func get(withUserID: String?, withDocumentID: String,
                    oncompletion: @escaping (TodoItem?, Error?) -> Void ) {    
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        let withUserID = withUserID ?? "default"
        
        database.retrieve(withDocumentID) {
            document, error in
            
            guard let document = document else {
                oncompletion(nil, error)
                return
            }
            
            guard let userID = document["user"].string else {
                oncompletion(nil, error)
                return
            }
            
            guard withUserID == userID else {
                oncompletion(nil, TodoCollectionError.AuthError)
                return
            }
            
            guard let documentID = document["_id"].string else {
                oncompletion(nil, error)
                return
            }
            
            guard let title = document["title"].string else {
                oncompletion(nil, error)
                return
            }
            
            guard let rank = document["rank"].int else {
                oncompletion(nil, error)
                return
            }
            
            guard let completed = document["completed"].bool else {
                oncompletion(nil, error)
                return
            }
            
            //let completedValue = completed == 1 ? true : false
            
            let todoItem = TodoItem(documentID: documentID, userID: userID, rank: rank,
                                    title: title, completed: completed)
            
            oncompletion(todoItem, nil)
        }
        
    }
    
    public func add(userID: String?, title: String, rank: Int = 0, completed: Bool = false,
                    oncompletion: @escaping (TodoItem?, Error?) -> Void ) {
        
        let userID = userID ?? "default"
        let json: [String: Any] = [
            "type": "todo",
            "user": userID,
            "title": title,
            "rank": rank,
            "completed": completed
        ]
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        print("String[]: \(json)")
        let x = JSON(json)
        print("JSON: \(x.rawString() as String?)")
        database.create(JSON(json)) {
            id, rev, document, error in
            
            if let id = id {
                let todoItem = TodoItem(documentID: id, userID: userID, rank: rank,
                                        title: title, completed: completed)
                
                oncompletion(todoItem, nil)
            } else {
                oncompletion(nil, error)
            }
            
        }
    }
    
    public func update(documentID: String, userID: String?, title: String?,
                       rank: Int?, completed: Bool?, oncompletion: @escaping (TodoItem?, Error?) -> Void ) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        
        let userID = userID ?? "default"
        
        database.retrieve(documentID) {
            document, error in
            
            guard let document = document else {
                oncompletion(nil, TodoCollectionError.AuthError)
                return
            }
            
            guard userID == document["user"].string else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }
            
            guard let rev = document["_rev"].string else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }
            
            let type = "todo"
            let user = userID
            let title = title ?? document["title"].string!
            let rank = rank ?? document["rank"].int!
            let completed = completed ?? document["completed"].bool!
            /*var completedValue : Int
            
            if let completed = completed {
                completedValue = completed ? 1 : 0
            } else {
                completedValue = document["completed"].int!
            }
            
            let completedBool = completedValue == 1 ? true : false*/
            
            let json: [String: Any] = [
                "type": type,
                "user": user,
                "title": title,
                "rank": rank,
                "completed": completed
            ]
            
            database.update(documentID, rev: rev, document: JSON(json)) {
                rev, document, error in
                
                guard error == nil else {
                    oncompletion(nil, error)
                    return
                }
                oncompletion (TodoItem(documentID: documentID, userID: user, rank: rank, title: title, completed: completed), nil)
            }  
        }
    }
    
    public func delete(withUserID: String?, withDocumentID: String, oncompletion: @escaping (Error?) -> Void) {
        
        let couchDBClient = CouchDBClient(connectionProperties: connectionProperties)
        let database = couchDBClient.database(databaseName)
        let withUserID = withUserID ?? "default"
        
        database.retrieve(withDocumentID) {
            document, error in
            
            guard let document = document else {
                oncompletion(error)
                return
            }
            
            let rev = document["_rev"].string!
            let user = document["user"].string!
            
            if withUserID == user {
                database.delete( withDocumentID, rev: rev) {
                    error in       
                    oncompletion(nil)
                }
            }     
        }   
    }

    private func setupDatabaseDesign(db:Database) {
        let design : [String:Any] = [
            "_id": "_design/todosdesign",
            "views" : [
                "all_todos" : [
                    "map" : "function(doc) { if (doc.type == 'todo') { emit(doc._id, [doc._id, doc.user, doc.title, doc.completed, doc.rank]); }}"
                ],
                "user_todos": [
                    "map": "function(doc) { if (doc.type == 'todo') { emit(doc.user, [doc._id, doc.user, doc.title, doc.completed, doc.rank]); }}"
                ],
                "total_todos": [
                    "map" : "function(doc) { if (doc.type == 'todo') { emit(doc.id, 1); }}",
                    "reduce" : "_count"
                ]
            ]
        ]
        
        db.createDesign(self.designName, document: JSON(design), callback: {
            json, error in
            
            if (error != nil) {
                Log.error("Bad news! Creating design caused a failure: \(error as Error?)")
            } else {
                Log.info("Good news! We created the design \(json as JSON?)")
            }
        })
    }

    private func setupDB() {
        let couchDBClient = CouchDBClient(connectionProperties: self.connectionProperties)
        couchDBClient.dbExists(databaseName, callback: {
            exists, error in
            
            if (exists) {
                Log.info("Good news! Database exists")
            } else {
                Log.error("Bad news! Database does not exist \(error as Error?)")
                couchDBClient.createDB(self.databaseName, callback: {
                    database, error in
                    
                    if (database != nil) {
                        Log.info("Good news!  We created the database")
                        self.setupDatabaseDesign(db: database!)
                    } else {
                        Log.error("Bad news!  We were not able to create the database \(self.databaseName) due to error: \(error as Error?)")
                    }
                })
            }
        })
    }
}

func parseGetIDandRev(_ document: JSON) throws -> [(String, String)] {
    guard let rows = document["rows"].array else {
        throw TodoCollectionError.ParseError
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
        throw TodoCollectionError.ParseError
    }
    
    let todos: [TodoItem] = rows.flatMap {   
        let doc = $0["value"]  
        guard   let id = doc[0].string,
                let user = doc[1].string,
                let title = doc[2].string,
                let completed = doc[3].bool,
                let rank = doc[4].int else {
                return nil           
        }
        return TodoItem(documentID: id, userID: user, rank: rank, title: title, completed: completed)
    }
    return todos
}
