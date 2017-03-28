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



/**
 TodoListAPI

 TodoCollection defines the basic operations for todo lists
 */
public protocol TodoListAPI {
    func count(withUserID: String?, oncompletion: @escaping (Int?, Error?) -> Void)
    func clear(withUserID: String?, oncompletion: @escaping (Error?) -> Void)
    func clearAll(oncompletion: @escaping (Error?) -> Void)
    func get(withUserID: String?, oncompletion: @escaping ([TodoItem]?, Error?) -> Void)
    func get(withUserID: String?, withDocumentID: String, oncompletion: @escaping (TodoItem?, Error?) -> Void )
    func add(userID: String?, title: String, rank: Int, completed: Bool,
    oncompletion: @escaping (TodoItem?, Error?) -> Void )
    func update(documentID: String, userID: String?, title: String?, rank: Int?,
    completed: Bool?, oncompletion: @escaping (TodoItem?, Error?) -> Void )
    func delete(withUserID: String?, withDocumentID: String, oncompletion: @escaping (Error?) -> Void)}
