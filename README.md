# Todolist CouchDB

Todolist implemented for Cloudant (CouchDB) backend

Quick start:

- Download the [Swift DEVELOPMENT 05-03 snapshot](https://swift.org/download/#snapshots)
- Download CouchDB
  You can use `brew install couchdb` or `apt-get install couchdb`
- Clone the TodoList CouchDB repository
- Fetch the test cases by running `git submodule init` then `git submodule update`
- Compile the library with `swift build` on Mac OS or `swift build -Xcc -fblocks` on Linux
- Run the test cases with `swift test`

## Deploying to BlueMix

1. Get an account for [Bluemix](https://new-console.ng.bluemix.net/?direct=classic)

2. Dowload and install the [Cloud Foundry tools](https://new-console.ng.bluemix.net/docs/starters/install_cli.html):

    ```
    cf login
    bluemix api https://api.ng.bluemix.net
    bluemix login -u username -o org_name -s space_name
    ```

    Be sure to change the directory to the Kitura-TodoList directory where the manifest.yml file is located.

3. Run `cf push`

    ***Note** The uploading droplet stage should take a long time, roughly 5-7 minutes. If it worked correctly, it should say:

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

5. Create a new design in Cloudant

    Log in to Bluemix, and select New View. Create a new design called `_design/example`. Inside of the design example, create 2 views:

6. Create a view named `all_todos` in the example design:

    This view will return all of the todo elements in your database. Add the following Map function:

    ```javascript
    function(doc) {
        if (doc.type == 'todo' && doc.active) {
            emit(doc._id, [doc.title, doc.completed, doc.order]);
        }
    }
    ```

    Leave Reduce as None.

7. Create a view named `total_todos` in the example design:

    This view will return the count of all the todo documents in your database.

    ```javascript
    function(doc) {
        if (doc.type == 'todo' && doc.active) {
            emit(doc.id, 1);
        }
    }
    ```

    Set the reduce function to `_count` which will tally all of the returned documents.

Example design file:

```
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

8. Push design to bluemix using 
```
curl -u "'bluemixServiceUserName':'bluemixServicePassword'" -X PUT 'bluemixServiceURL'/todlist/_design/'databaseName'--data-binary @'designFileName'
```
