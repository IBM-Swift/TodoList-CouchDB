# ToDo CouchDB and Cloudant backend

[![Build Status](https://travis-ci.org/IBM-Swift/TodoList-CouchDB.svg?branch=master)](https://travis-ci.org/IBM-Swift/TodoList-CouchDB)

## Quick start for local development:

1. Download [Xcode 8](https://swift.org/download/)
2. Download [CouchDB](http://couchdb.apache.org/)
 
 You can use `brew install couchdb` 

3. Clone the TodoList CouchDB repository:

  `git clone https://github.com/IBM-Swift/TodoList-CouchDB`
  
4. Install the test cases:

  `git clone https://github.com/IBM-Swift/todolist-tests Tests`
  
5. Make an XCode project

  `swift package generate-xcodeproj`
  
## Quick start on Linux

1. Install the [Swift 3.0 RELEASE toolchain](http://www.swift.org)

2. Install CouchDB:

  `sudo apt-get install couchdb`
  
3. Clone the repository:

  `git clone https://github.com/IBM-Swift/TodoList-CouchDB`
  
4. Compile the project with `swift build` on Linux

5. Run the server:

 `.build/debug/Deploy`

## Deploying to BlueMix

1. Get an account for [Bluemix](https://new-console.ng.bluemix.net/?direct=classic)

2. Download and install the [Cloud Foundry tools](https://new-console.ng.bluemix.net/docs/starters/install_cli.html):

    ```
    cf login
    bluemix api https://api.ng.bluemix.net
    bluemix login -u username -o org_name -s space_name
    ```

    Be sure to run this in the directory where the manifest.yml file is located.

3. Run `cf push`   

    ***Note** This step could take a few minutes

    ```
    1 of 1 instances running 

    App started
    ```

4. Add a `url` environment variable, with the hostname of the application, to the app on bluemix.
   To add environment variables on the 'new console' bluemix: go to compute -> <App> -> Runtime -> Environment Variables 

5. Create the Cloudant backend and attach it to your instance.

    ```
    cf create-service cloudantNoSQLDB Shared database_name
    cf bind-service Kitura-TodoList database_name
    cf restage
    ```
6. On the Bluemix console, click on the service created in step 4. Click on the green button titled `Launch`

7. Click on `Create Database` near the top right of the page after launching. Name the database whatever (repo is currently set to expect database name to be `todo`)

8. Create a design file.

  Example design file:
  
  ```json
  {
  "_id": "_design/tododb",
  "views" : {
    "all_todos" : {
      "map" : "function(doc) { if (doc.type == 'todo') { emit(doc._id, [doc._id, doc.user, doc.title, doc.completed, doc.rank]); }}"
    },
    "user_todos": {
         "map": "function(doc) { if (doc.type == 'todo') { emit(doc.user, [doc._id, doc.user, doc.title, doc.completed, doc.rank]); }}"
    },
    "total_todos": {
      "map" : "function(doc) { if (doc.type == 'todo') { emit(doc.id, 1); }}",
      "reduce" : "_count"
    }
  }
  }
  ```

9. Go back to the service's main page and click on `Service Credentials` which can be found directly under the service name.

10. Click on the blue button `Add New Credential` and add a new credential.

11. Push design to Bluemix using 
  ```
  curl -u "'bluemixServiceUserName':'bluemixServicePassword'" -X PUT 'bluemixServiceURL'/todolist/_design/'databaseName' --data-binary @'designFileName'
  ```
  
  - 'bluemixServiceUserName', 'bluemixServicePassword', and 'bluemixServiceURL' come from the credential made in step 9
  - 'databaseName' comes from the database made in step 6
  - 'designFileName' comes from the design file made in step 7
  
## License

Copyright 2016 IBM

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
