#!/bin/bash

# Delete existing database
curl -u $2:$3 -X DELETE $1/todolist
curl -u $2:$3 -X PUT $1/todolist
curl -u $2:$3 -X PUT $1/todolist/_design/todosdesign --data-binary @mydesign.json
