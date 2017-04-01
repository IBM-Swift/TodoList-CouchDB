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

import Kitura
import HeliumLogger
import LoggerAPI
import CloudFoundryDeploymentTracker
import TodoList
import Configuration
import CloudFoundryConfig

HeliumLogger.use()

let configFile = "cloud_config.json"
let databaseName = "todolist"

extension TodoList {
    
    public convenience init(config: CloudantService) {
        
        self.init(host: config.host, port: UInt16(config.port),
                  username: config.username, password: config.password)
    }
}

let todos: TodoList

let manager = ConfigurationManager()

do {
    manager.load(.environmentVariables).load(file: configFile)
    let cloudantConfig = try manager.getCloudantService(name: "TodoListCloudantDatabase")
    todos = TodoList(config: cloudantConfig)
    
} catch {
    todos = TodoList()
}

let controller = TodoListController(backend: todos)

let port = manager.port
Log.verbose("Assigned port is \(port)")

CloudFoundryDeploymentTracker(repositoryURL: "https://github.com/IBM-Swift/TodoList-CouchDB.git").track()
Kitura.addHTTPServer(onPort: port, with: controller.router)
Kitura.run()
