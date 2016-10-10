# TodoList Tests

Testing suite for adding, updating, deleting, and getting todo list items from a database.

- The testing framework will work for any project that uses the [TodoList API](https://github.com/IBM-Swift/todolist-api).
- For example web services, take a look at some of example implementations based on [boilerplates](https://github.com/IBM-Swift/todolist-boilerplate):
- [Swagger API](https://github.com/IBM-Swift/todolist-swagger) for building a service


## Database Unit Tests

 1. Clone the tests repo to your project path in the directory Tests.

  Make sure you are in the project root directory. The one with Sources subdirectory, the Package.swift file, and the manifest.yml file. Clone the repo and use Tests as the directory name

  `git clone https://github.com/IBM-Swift/todolist-tests Tests`
  
 2. Run the tests on the terminal after you have compiled your application:

  ```
  swift build <flags go here>
  swift test
  ```

## Integration tests

The todobackend site provides their own reference specs and tests, 9/9 tests should pass both when running locally and when it has been deployed to your server.

 1. Run the tests locally:
 
  First, make sure that your tests all pass when your web service is running locally on port 8090:
  
  http://www.todobackend.com/specs/index.html?http://localhost:8090

2. Press 'choose different server to target` or directly change the URL to use your deployed service URL:

  As an example, if your URL is kitura-todolist.mybluemix.net, then the link would be:
  
  http://www.todobackend.com/specs/index.html?http://kitura-todolist.mybluemix.net
