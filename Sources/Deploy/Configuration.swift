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
*/

import Foundation
import CouchDB
import SwiftyJSON
import LoggerAPI
import CloudFoundryEnv

public struct Configuration {

    private static var configurationFile = "cloud_config.json"

    public static func getConfiguration() -> JSON? {
        do {
            let path = Configuration.getAbsolutePath(relativePath: "/\(configurationFile)", useFallback: false)
            if let finalPath = path {
                let data = try Data(contentsOf: URL(fileURLWithPath: finalPath))
                let configJson = JSON(data: data)
                Log.info("Using configuration values from '\(configurationFile)'.")
                return configJson["VCAP_SERVICES"]
            } else {
                Log.warning("Could not find '\(configurationFile)'.")
                return nil
            }
        } catch {
            return nil
        }
    }

    private static func getAbsolutePath(relativePath: String, useFallback: Bool) -> String? {
        let initialPath = #file
        let components = initialPath.characters.split(separator: "/").map(String.init)
        let notLastThree = components[0..<components.count - 3]
        var filePath = "/" + notLastThree.joined(separator: "/") + relativePath
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            return filePath
        } else if useFallback {
            // Get path in alternate way, if first way fails
            let currentPath = fileManager.currentDirectoryPath
            filePath = currentPath + relativePath
            if fileManager.fileExists(atPath: filePath) {
                return filePath
            } else {
                return nil
            }
        } else {
              return nil
        }
    }

}
