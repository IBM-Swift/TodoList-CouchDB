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
import XCTest

@testable import TodoList

class TestTodoList: XCTestCase {

    static var allTests: [(String, (TestTodoList) -> () throws -> Void )] {
        return [
            ("testAddItem", testAddItem),
            ("testRemoveItem", testRemoveItem),
            ("testGetAllItems", testGetAllItems),
            ("testUpdateAll", testUpdateAll),
            ("testUpdateTitle", testUpdateTitle),
            ("testUpdateCompleted", testUpdateCompleted),
            ("testUpdateOrder", testUpdateOrder),
            ("testClear", testClear)
        ]
    }

    var todos: TodoList?

    override func setUp() {

        todos = TodoList()

        super.setUp()
    }


    func testAddItem() {

        guard let todos = todos else {
            XCTFail()
            return
        }

        let expectation1 = expectation(description: "Add first item")


        todos.add(userID: "testAdd", title: "Reticulate splines", rank: 0, completed: false) {
            firstitem, error in

            if let firstitem = firstitem {
                todos.get(withUserID: "testAdd", withDocumentID: firstitem.documentID) {
                    fetchedtodo, error in

                    XCTAssertEqual(firstitem, fetchedtodo)

                    expectation1.fulfill()
                }
            }


        }



        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })

    }

    func testRemoveItem() {

        guard let todos = todos else {
            XCTFail()
            return
        }

        let expectation1 = expectation(description: "Remove item")

        todos.clearAll() {
            error in
        }

        todos.add(userID: "testRemove", title: "Reticulate splines", rank: 0, completed: true) {
            newitem, error in
            //XCTAssertEqual(todos.count, 1, "There must be 1 element in the collection")
            if let newitem = newitem {
                todos.delete(withUserID: "testRemove", withDocumentID: newitem.documentID,
                             oncompletion: {
                                error in

                                todos.count(withUserID: "testRemove") { count, error in

                                    XCTAssertEqual(count, 0, "There must be 0 elements in the" +
                                        "collection after delete")
                                    expectation1.fulfill()
                                }

                })
            }
        }




        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }


    func testClear() {

        guard let todos = todos else {
            XCTFail()
            return
        }

        let expectation1 = expectation(description: "Clear all items")

        todos.clearAll() {
            error in

        }
        todos.count(withUserID: nil) {
            count, error in

            XCTAssertEqual(count, 0)

            expectation1.fulfill()
        }




        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })
    }

    func testGetAllItems() {

        guard let todos = todos else {
            XCTFail()
            return
        }

        // try! todos.clear(){}

        let expectationGetAll = expectation(description: "Get all items")

        todos.clearAll() {
            error in

            todos.add(userID: "testGetAll", title: "Reticulate splines", rank: 0, completed: true) {
                _, error in


                todos.get(withUserID: "testGetAll") {
                    results, error in

                    if let results = results {
                        XCTAssertEqual(results.count, 1, "There must be at least 1 element in the" +
                            "collection")
                    }

                    expectationGetAll.fulfill()
                }


            }

        }

        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })


    }

    func testUpdateAll() {

        guard let todos = todos else {
            XCTFail()
            return
        }

        todos.clearAll() {
            error in
        }

        let addExpectation = expectation(description: "Add item")
        let updateExpectation = expectation(description: "Update item")


        todos.add(userID: "testUpdateAll", title: "Reticulate splines", rank: 5, completed: false) {
            result, error in

            addExpectation.fulfill()

            if let result = result {
                todos.update(documentID: result.documentID, userID: "testUpdateAll",
                             title: "Obfuscate dictionary", rank: 2, completed: true) {

                                updatedItem, error in

                                let correctItem = TodoItem(documentID: result.documentID,
                                                           userID: "testUpdateAll",
                                                           rank: 2,
                                                           title: "Obfuscate dictionary",
                                                           completed: true)

                                XCTAssertEqual(updatedItem, correctItem)

                                updateExpectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })

    }

    func testUpdateTitle() {

        guard let todos = todos else {
            XCTFail()
            return
        }

        todos.clearAll() {
            error in
        }

        let addExpectation = expectation(description: "Add item")
        let updateExpectation = expectation(description: "Update item")

        todos.add(userID: "testUpdateTitle", title: "Reticulate splines", rank: 5,
                  completed: false) {
                    result, error in

                    addExpectation.fulfill()

                    if let result = result {
                        todos.update(documentID: result.documentID, userID: "testUpdateTitle",
                                     title: "Obfuscate dictionary", rank: nil, completed: nil) {
                                        updatedItem, error in

                                        let correctItem = TodoItem(documentID: result.documentID,
                                                                   userID: "testUpdateTitle", rank: 5,
                                                                   title: "Obfuscate dictionary",
                                                                   completed: false)
                                        let originalItem = TodoItem(documentID: result.documentID,
                                                                    userID: "testUpdateTitle",
                                                                    rank: 5,
                                                                    title: "Reticulate splines",
                                                                    completed: false)

                                        XCTAssertEqual(updatedItem, correctItem)
                                        XCTAssertNotEqual(updatedItem, originalItem)

                                        updateExpectation.fulfill()
                        }
                    }
        }

        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })

    }

    func testUpdateCompleted() {

        guard let todos = todos else {
            XCTFail()
            return
        }

        todos.clearAll() {
            error in
        }

        let addExpectation = expectation(description: "Add item")
        let updateExpectation = expectation(description: "Update item")

        todos.add(userID: "testUpdateCompleted", title: "Reticulate splines", rank: 5,
                  completed: false) {
                    result, error in

                    addExpectation.fulfill()

                    if let result = result {
                        todos.update(documentID: result.documentID, userID: "testUpdateCompleted",
                                     title: nil, rank: nil, completed: true) {
                                        updatedItem, error in

                                        let correctItem = TodoItem(documentID: result.documentID,
                                                                   userID: "testUpdateCompleted",
                                                                   rank: 5,
                                                                   title: "Reticulate splines",
                                                                   completed: true)
                                        let originalItem = TodoItem(documentID: result.documentID,
                                                                    userID: "testUpdateCompleted",
                                                                    rank: 5, title: "Reticulate splines",
                                                                    completed: false)

                                        XCTAssertEqual(updatedItem, correctItem)
                                        XCTAssertNotEqual(updatedItem, originalItem)

                                        updateExpectation.fulfill()
                        }
                    }
        }

        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })

    }

    func testUpdateOrder() {

        guard let todos = todos else {
            XCTFail()
            return
        }

        let addExpectation = expectation(description: "Add item")
        let updateExpectation = expectation(description: "Update item")

        todos.clearAll() {
            error in
        }

        todos.add(userID: "testUpdateOrder", title: "Reticulate splines", rank: 5,
                  completed: false) {
                    result, error in

                    addExpectation.fulfill()

                    if let result = result {
                        todos.update(documentID: result.documentID, userID: "testUpdateOrder",
                                     title: nil, rank: 12, completed: nil) {
                                        updatedItem, error in

                                        let correctItem = TodoItem(
                                            documentID: result.documentID,
                                            userID: "testUpdateOrder",
                                            rank: 12,
                                            title: "Reticulate splines",
                                            completed: false)
                                        let originalItem = TodoItem(
                                            documentID: result.documentID,
                                            userID: "testUpdateOrder",
                                            rank: 5,
                                            title: "Reticulate splines",
                                            completed: false)

                                        XCTAssertEqual(updatedItem, correctItem)
                                        XCTAssertNotEqual(updatedItem, originalItem)

                                        updateExpectation.fulfill()
                        }
                    }
        }


        waitForExpectations(timeout: 5, handler: { error in XCTAssertNil(error, "Timeout") })

    }

}
