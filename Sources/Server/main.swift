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
import TodoList
import CloudEnvironment

HeliumLogger.use()

extension TodoList {
    public convenience init(config: CloudantCredentials?) {
        if let config = config {
            self.init(host: config.host, port: UInt16(config.port), username: config.username, password: config.password)
        } else {
            self.init()
            Log.warning("Could not load credentials.")
            return
        }
    }
}

let todos: TodoList
let cloudEnv = CloudEnv()

let cloudantCredentials = cloudEnv.getCloudantCredentials(name: "MyCloudantDB")
todos = TodoList(config: cloudantCredentials)
let controller = TodoListController(backend: todos)

let port = cloudantCredentials!.port
let url = cloudantCredentials!.url
Log.verbose("Assigned port is \(port)")
Log.verbose("Assigned URL is \(url)")
Kitura.addHTTPServer(onPort: 8080, with: controller.router)
Kitura.run()
