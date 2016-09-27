# ToDo CouchDB and Cloudant backend

Todo backend is an example of using the [Kitura](https://github.com/IBM-Swift/Kitura) Swift framework for building a productivity app with a database for storage of tasks.

[![Build Status](https://travis-ci.org/IBM-Swift/TodoList-CouchDB.svg?branch=master)](https://travis-ci.org/IBM-Swift/TodoList-CouchDB)
![](https://img.shields.io/badge/Swift-3.0%20RELEASE-orange.svg?style=flat)
![](https://img.shields.io/badge/platform-Linux,%20macOS-blue.svg?style=flat)

## Quick start for local development:

You can set up your development environment and use XCode 8 for editing, building, debugging, and testing your server application. To use XCode, you must use the command line tools for generating an XCode project.

1. Download [Xcode 8](https://swift.org/download/)
2. Download [CouchDB](http://couchdb.apache.org/)
 
 You can use `brew install couchdb` 

3. Clone the TodoList CouchDB repository:

  `git clone https://github.com/IBM-Swift/TodoList-CouchDB`
  
4. Install the test cases:

  `git clone https://github.com/IBM-Swift/todolist-tests Tests`
  
5. Make an XCode project

  `swift package generate-xcodeproj`
  
6. Set up your database

  `./Database/setup.sh http://localhost:5984 username password`
  
## Quick start on Linux

To build the project in Linux, you need to first install the Swift 3 toolchain.

1. Install the [Swift 3.0 RELEASE toolchain](http://www.swift.org)

2. Install CouchDB:

  `sudo apt-get install couchdb`
  
3. Clone the repository:

  `git clone https://github.com/IBM-Swift/TodoList-CouchDB`
  
4. Compile the project with `swift build` on Linux

5. Run the server:

 `.build/debug/Deploy`
 
6. Set up your database

  `./Database/setup.sh http://localhost:5984 username password`

## Deploying to Bluemix

### Using the IBM Cloud Tools for Swift

The TodoList for Cloudant is deployable with a graphical user interface. Download:

- [IBM Cloud Tools for Swift](http://cloudtools.bluemix.net/)

### Deploy to Bluemix Button

You can use this button to deploy ToDo your Bluemix account, all from the browser. The button will create the application, create and bind any services specified in the manifest.yml file and deploy.

[![Deploy to Bluemix](https://bluemix.net/deploy/button.png)](https://bluemix.net/deploy?repository=https://github.com/IBM-Swift/TodoList-CouchDB)

### Manually

Bluemix is a hosting platform from IBM that makes it easy to deploy your app to the cloud. Bluemix also provides various popular databases. [Cloudant](https://cloudant.com/) is an offering that is compatible with the CouchDB database, but provides additional features. You can use Cloudant with your deployed TodoList-CouchDB application.

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

4. Create the Cloudant backend and attach it to your instance.

    ```
    cf create-service cloudantNoSQLDB Shared database_name
    cf bind-service TodoListCloudantApp TodoListCloudantDatabase
    cf restage
    ```
5. Setup your database

    Run `cf env` or use the Bluemix dashboard to discover the hostname, username, and password. Run the setup script, passing
    in these variables through command line arguments

    ```
    cd Database
    ./setup.sh BLUEMIX_DATABASE_HOST USERNAME PASSWORD
    ```

    For example,
    ```
    ./setup.sh https://1e2e6460-4090-4e6d-8d37-70f308ae2155-bluemix.cloudant.com:443  \
               1e2e6460-4090-4e6d-8d37-70f308ae2155-bluemix \
               somepassword
    ```
  
## License

Copyright 2016 IBM

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
