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
import LoggerAPI
import CloudFoundryEnv

struct ConfigurationError : LocalizedError {
    var errorDescription: String? { return "Could not read configuration information" }
}

func getConfiguration(configFile: String) throws -> Service {
    var appEnv: AppEnv?
    do {
        let path = getAbsolutePath(relativePath: "/\(configFile)", useFallback: false)
        if path != nil {
            let data = try Data(contentsOf: URL(fileURLWithPath: path!))
            if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] {
                appEnv = try CloudFoundryEnv.getAppEnv(options: jsonDictionary)
                Log.info("Using configuration values from '\(configFile)'.")
            }
        }
        Log.warning("AppENV status: \(appEnv)")
        if appEnv == nil {
            Log.warning("No \(configFile) using CloudFoundry environment instead.")
            appEnv = try CloudFoundryEnv.getAppEnv()
        }
        Log.warning("AppENV status NOW: \(appEnv)")
        
        let services = appEnv!.getServices()
        let servicePair = services.filter { element in element.value.label == "cloudantNoSQLDB" }.first
        guard let service = servicePair?.value else {
            throw ConfigurationError()
        }
 
        return service
        
    } catch {
        Log.warning("An error occurred while trying to read configurations.")
        throw ConfigurationError()
    }
}

func getAbsolutePath(relativePath: String, useFallback: Bool) -> String? {
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
        return fileManager.fileExists(atPath: filePath) ? filePath : nil
    } else {
        return nil
    }
}

