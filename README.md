# Todolist CouchDB/Cloudant backend
[![Build Status](https://travis-ci.org/IBM-Swift/todolist-couchdb.svg?branch=master)](https://travis-ci.org/IBM-Swift/todolist-couchdb)
[![Swift 3 6-06](https://img.shields.io/badge/Swift%203-6/20 SNAPSHOT-blue.svg)](https://swift.org/download/#snapshots)

Todolist implemented for CouchDB or Cloudant backend

Quick start:


- Download the [Swift DEVELOPMENT 06-20 snapshot](https://swift.org/download/#snapshots)
- Download CouchDB
  You can use `brew install couchdb` or `apt-get install couchdb`
- Clone the TodoList CouchDB repository
- Fetch the test cases by running `git submodule init` then `git submodule update`
- Compile the library with `swift build` on Mac OS or `swift build -Xcc -fblocks` on Linux
- Run the test cases with `swift test`

## Deploying to BlueMix

1. Get an account for [Bluemix](https://new-console.ng.bluemix.net/?direct=classic)

2. Download and install the [Cloud Foundry tools](https://new-console.ng.bluemix.net/docs/starters/install_cli.html):

    ```
    cf login
    bluemix api https://api.ng.bluemix.net
    bluemix login -u username -o org_name -s space_name
    ```

    Be sure to change the directory to the Kitura-TodoList directory where the manifest.yml file is located.

3. Run `cf push`

    ***Note** This step could take a few minutes

    ```
    1 of 1 instances running 

    App started
    ```

4. Create the Cloudant backend and attach it to your instance.

    ```
    cf create-service cloudantNoSQLDB Shared database_name
    cf bind-service Kitura-TodoList database_name
    cf restage
    ```
5. On the Bluemix console, click on the service created in step 4. Click on the green button titled `Launch`

6. Click on `Create Database` near the top right of the page after launching. Name the database whatever (repo is currently set to expect database name to be `todo`)

7. Create a design file.

  Example design file:
  
  ```json
  {
  "_id": "_design/tododb",
  "views" : {
    "all_todos" : {
      "map" : "function(doc) { if (doc.type == 'todo') { emit(doc._id, [doc._id, doc.user, doc.title, doc.completed, doc.order]); }}"
    },
    "user_todos": {
         "map": "function(doc) { if (doc.type == 'todo') { emit(doc.user, [doc._id, doc.user, doc.title, doc.completed, doc.order]); }}"
    },
    "total_todos": {
      "map" : "function(doc) { if (doc.type == 'todo') { emit(doc.id, 1); }}",
      "reduce" : "_count"
    }
  }
  }
  ```

8. Go back to the service's main page and click on `Service Credentials` which can be found directly under the service name.

9. Click on the blue button `Add New Credential` and add a new credential.

10. Push design to Bluemix using 
  ```
  curl -u "'bluemixServiceUserName':'bluemixServicePassword'" -X PUT 'bluemixServiceURL'/todolist/_design/'databaseName' --data-binary @'designFileName'
  ```
  
  - 'bluemixServiceUserName', 'bluemixServicePassword', and 'bluemixServiceURL' come from the credential made in step 9
  - 'databaseName' comes from the database made in step 6
  - 'designFileName' comes from the design file made in step 7
  
