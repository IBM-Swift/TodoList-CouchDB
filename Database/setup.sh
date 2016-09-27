#!/bin/bash

# Delete existing database

if [ "$1" ]; then
    echo "Setting up Cloudant database on $1"
    curl -u $2:$3 -X DELETE $1/todolist
    curl -u $2:$3 -X PUT $1/todolist
    curl -u $2:$3 -X PUT $1/todolist/_design/todosdesign --data-binary @mydesign.json;
else
    echo "Setting up local CouchDB database..."
    curl -X DELETE http://localhost:5984/todolist
    curl -X PUT http://localhost:5984/todolist
    curl -X PUT http://localhost:5984/todolist/_design/todosdesign --data-binary @mydesign.json
fi;
