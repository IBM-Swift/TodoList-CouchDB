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

public struct TodoItem {

    public let documentID: String

    public let userID: String?

    public let rank: Int

    /// Text to display
    public let title: String

    /// Whether completed or not
    public let completed: Bool

    public init(documentID: String, userID: String? = nil, rank: Int, title: String, completed: Bool) {
        self.documentID = documentID
        self.userID = userID
        self.rank = rank
        self.title = title
        self.completed = completed
    }

}


extension TodoItem : Equatable { }

public func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
    return lhs.documentID == rhs.documentID && lhs.userID == rhs.userID && lhs.rank == rhs.rank &&
        lhs.title == rhs.title && lhs.completed == rhs.completed

}
