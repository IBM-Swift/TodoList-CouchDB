#!/bin/bash

# Delete existing database
curl -X DELETE http://127.0.0.1:5984/todolist
curl -X PUT http://127.0.0.1:5984/todolist
curl -X PUT http://127.0.0.1:5984/todolist/_design/example --data-binary @mydesign.json
