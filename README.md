# Todolist CouchDB/Cloudant backend
[![Build Status](https://travis-ci.org/IBM-Swift/TodoList-CouchDB.svg?branch=master)](https://travis-ci.org/IBM-Swift/TodoList-CouchDB)

Todolist implemented for CouchDB or Cloudant backend

Quick start:

- Download [Xcode 8](https://swift.org/download/)
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

4. Add a `url` environment variable, with the hostname of the application,to the app on bluemix.    

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
  
