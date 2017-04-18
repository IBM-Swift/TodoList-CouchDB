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
import Configuration

typealias JSONDictionary = [String : Any]

let localServerURL = "http://localhost:8080"

protocol DictionaryConvertible {
    func toDictionary() -> JSONDictionary
}

extension TodoItem : DictionaryConvertible {
    var url: String {
        
        let url: String
        
        let manager = ConfigurationManager()
        manager.load(.environmentVariables)

        if let configUrl = manager["VCAP_APPLICATION:uris:0"] as? String {
            url = "https://" + configUrl
        }
        else {
            url = manager["url"] as? String ?? localServerURL
        }
        return url + "/api/todos/" + documentID
    }
    
    func toDictionary() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = self.documentID
        result["user"] = self.userID
        result["order"] = self.rank
        result["title"] = self.title
        result["completed"] = self.completed
        result["url"] = self.url
        return result
    }
}

extension Array where Element : DictionaryConvertible {
    func toDictionary() -> [JSONDictionary] {
        return self.map { $0.toDictionary() }
    }
}
