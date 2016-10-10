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

import Kitura
import LoggerAPI
import SwiftyJSON
import TodoListAPI
import Credentials
import CredentialsFacebook

class AllRemoteOriginMiddleware: RouterMiddleware {
    func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Swift.Void) {
        response.headers["Access-Control-Allow-Origin"] = "*"
        next()
    }
}

public final class TodoListController {
    public let todosPath = "api/todos"
    public let todos: TodoListAPI
    public let router = Router()

    private let credentialsMiddleware = Credentials()
    private let fbCredentialsPlugin = CredentialsFacebookToken()

    public init(backend: TodoListAPI) {
        self.todos = backend
        credentialsMiddleware.register(plugin: fbCredentialsPlugin)
        setupRoutes()
    }

    private func setupRoutes() {
        let id = "\(todosPath)/:id"

        router.all("/*", middleware: BodyParser())
        router.all("/*", middleware: AllRemoteOriginMiddleware())
        //router.all("/*", middleware: credentialsMiddleware)
        router.get("/", handler: onGetTodos)
        router.get(id, handler: onGetByID)
        router.options("/*", handler: onGetOptions)
        router.post("/", handler: onAddItem )
        router.post(id, handler: onUpdateByID)
        router.patch(id, handler: onUpdateByID)
        router.delete(id, handler: onDeleteByID)
        router.delete("/", handler: onDeleteAll)
    }

    private func onGetTodos(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        let userID: String = request.userProfile?.id ?? "default"
        todos.get(withUserID: userID) {
            todos, error in
            do {
                guard error == nil else {
                    try response.status(.badRequest).end()
                    Log.error(error.debugDescription)
                    return
                }
                guard let todos = todos else {
                    try response.status(.internalServerError).end()
                    return
                }
                let json = JSON(todos.toDictionary())
                try response.status(.OK).send(json: json).end()
            } catch {
                Log.error("Communication error")
            }
        }
    }

    private func onGetByID(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let id = request.parameters["id"] else {
            response.status(.badRequest)
            Log.error("Request does not contain ID")
            return
        }

        let userID: String = request.userProfile?.id ?? "default"
        todos.get(withUserID: userID, withDocumentID: id) {
            item, error in
            do {
                guard error == nil else {
                    try response.status(.badRequest).end()
                    Log.error(error.debugDescription)
                    return
                }
                if let item = item {
                    let result = JSON(item.toDictionary())
                    try response.status(.OK).send(json: result).end()

                } else {
                    Log.warning("Could not find the item")
                    response.status(.badRequest)
                    return
                }
            } catch {
                Log.error("Communication error")
            }
        }
    }

    /**
     */
    private func onGetOptions(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        response.headers["Access-Control-Allow-Headers"] = "accept, content-type"
        response.headers["Access-Control-Allow-Methods"] = "GET,HEAD,POST,DELETE,OPTIONS,PUT,PATCH"
        response.status(.OK)
        next()
    }

    /**
     */
    private func onAddItem(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }

        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Body contains invalid JSON")
            return
        }

        let userID: String = request.userProfile?.id ?? "default"
        let title = json["title"].stringValue
        let rank = json["order"].intValue
        let completed = json["completed"].boolValue

        guard title != "" else {
            response.status(.badRequest)
            Log.error("Request does not contain valid title")
            return
        }

        todos.add(userID: userID, title: title, rank: rank, completed: completed) {
            newItem, error in
            do {
                guard error == nil else {
                    try response.status(.badRequest).end()
                    Log.error(error.debugDescription)
                    return
                }

                guard let newItem = newItem else {
                    try response.status(.internalServerError).end()
                    Log.error("Item not found")
                    return
                }

                let result = JSON(newItem.toDictionary())
                Log.info("\(userID) added \(title) to their TodoList")
                do {
                    try response.status(.OK).send(json: result).end()
                } catch {
                    Log.error("Error sending response")
                }
            } catch {
                Log.error("Communication error")
            }
        }
    }

    private func onUpdateByID(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let documentID = request.parameters["id"] else {
            response.status(.badRequest)
            Log.error("id parameter not found in request")
            return
        }

        guard let body = request.body else {
            response.status(.badRequest)
            Log.error("No body found in request")
            return
        }

        guard case let .json(json) = body else {
            response.status(.badRequest)
            Log.error("Body contains invalid JSON")
            return
        }

        let userID: String = request.userProfile?.id ?? "default"
        let title: String? = json["title"].stringValue == "" ? nil : json["title"].stringValue
        let rank = json["order"].intValue
        let completed = json["completed"].boolValue

        todos.update(documentID: documentID, userID: userID, title: title, rank: rank, completed: completed) {
            newItem, error in
            do {
                guard error == nil else {
                    try response.status(.badRequest).end()
                    Log.error(error.debugDescription)
                    return
                }
                if let newItem = newItem {
                    let result = JSON(newItem.toDictionary())
                    try response.status(.OK).send(json: result).end()
                } else {
                    Log.error("Database returned invalid new item")
                    try response.status(.badRequest).end()
                }
            } catch {
                Log.error("Communication error")
            }
        }
    }

    private func onDeleteByID(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        guard let documentID = request.parameters["id"] else {
            Log.warning("Could not parse ID")
            response.status(.badRequest)
            return
        }

        let userID: String = request.userProfile?.id ?? "default"

        todos.delete(withUserID: userID, withDocumentID: documentID) {
            error in
            do {
                guard error == nil else {
                    try response.status(.badRequest).end()
                    Log.error(error.debugDescription)
                    return
                }
                try response.status(.OK).end()
                Log.info("\(userID) deleted document \(documentID)")
            } catch {
                Log.error("Could not produce response")
            }
        }
    }

    private func onDeleteAll(request: RouterRequest, response: RouterResponse, next: () -> Void) {
        let userID: String = request.userProfile?.id ?? "default"
        todos.clearAll() {
            error in
            do {
                guard error == nil else {
                    try response.status(.badRequest).end()
                    Log.error(error.debugDescription)
                    return
                }
                try response.status(.OK).end()
                Log.info("\(userID) deleted all their documents")
            } catch {
                Log.error("Could not produce response")
            }
        }
    }
}
