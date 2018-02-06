// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

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

import PackageDescription


let package = Package(
    name: "TodoList",
    products: [],

    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git",                                from: "2.1.0"),
        .package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git",                        from: "2.0.0"),
        .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git",                      from: "6.0.0"),
        .package(url: "https://github.com/IBM-Bluemix/cf-deployment-tracker-client-swift.git",  from: "6.0.0")
    ],

    targets: [
        .target(
            name: "TodoList",
            dependencies: ["CloudEnvironment", "CouchDB", "Kitura"]
        ),
        .target(
            name: "Server",
            dependencies: [.target(name: "TodoList")]
        ),
        .testTarget(
            name: "TodoListTests",
            dependencies: ["TodoList"]
        )
        ]
)
