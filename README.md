# TodoList CouchDB and Cloudant backend

Todo backend is an example of using the [Kitura](https://github.com/IBM-Swift/Kitura) Swift framework for building a productivity app with a database for storage of tasks.

[![Build Status](https://travis-ci.org/IBM-Swift/TodoList-CouchDB.svg?branch=master)](https://travis-ci.org/IBM-Swift/TodoList-CouchDB)
![](https://img.shields.io/badge/Swift-3.0.2%20RELEASE-orange.svg?style=flat)
![](https://img.shields.io/badge/platform-Linux,%20macOS-blue.svg?style=flat)
![Bluemix Deployments](https://deployment-tracker.mybluemix.net/stats/9eef579b69ef97de1ef1083552adeea2/badge.svg)

## Quick start for local development:

You can set up your development environment and use XCode 8 for editing, building, debugging, and testing your server application. To use XCode, you must use the command line tools for generating an XCode project.

1. Download [Xcode 8](https://swift.org/download/)
2. Download [CouchDB](http://couchdb.apache.org/)
 
 You can use `brew install couchdb`

3. Clone the TodoList CouchDB repository:

  `git clone https://github.com/IBM-Swift/TodoList-CouchDB`
  
4. Make an XCode project

  `swift package generate-xcodeproj`
  
5. Start up CouchDB with the `couchdb` command.
  
6. Set up your database

  `cd Database && ./setup.sh`
  
7. Run the `Server` target in Xcode and access [http://localhost:8090/](http://localhost:8090/) in your browser to see an empty database.
  
## Quick start on Linux

To build the project in Linux, you need to first install the Swift 3 toolchain.

1. Install the [Swift 3.0 RELEASE toolchain](http://www.swift.org)

2. Install CouchDB:

  `sudo apt-get install couchdb`
  
3. Clone the repository:

  `git clone https://github.com/IBM-Swift/TodoList-CouchDB`
  
4. Compile the project with `swift build` on Linux
 
5. Set up your database

  `cd Database && ./setup.sh`

6. Run the server:

 `.build/debug/Server`
 
 Then access [http://localhost:8090/](http://localhost:8090/) in your browser to see an empty database.

## Deploying to Bluemix

### Using the IBM Cloud Tools for Swift

The TodoList for Cloudant is deployable with a graphical user interface. Download:

- [IBM Cloud Tools for Swift](http://cloudtools.bluemix.net/)

### Deploy to Bluemix Button

You can use this button to deploy TodoList to your Bluemix account, all from the browser. The button will create the application, create and bind any services specified in the manifest.yml file and deploy.

[![Deploy to Bluemix](https://deployment-tracker.mybluemix.net/stats/9eef579b69ef97de1ef1083552adeea2/button.svg)](https://bluemix.net/deploy?repository=https://github.com/IBM-Swift/TodoList-CouchDB.git)

### Deploying Docker to IBM Bluemix Container

1. Download and install the CloudFoundry CLI [here](https://github.com/cloudfoundry/cli/releases).

2. Install the IBM Containers plugin for CF:

  [Directions are here](https://console.ng.bluemix.net/docs/containers/container_cli_cfic_install.html) for different operating systems.
  

  ```
  cf install-plugin https://static-ice.ng.bluemix.net/ibm-containers-mac
  cf api https://api.ng.bluemix.net
  cf login 
  cf ic login
  ```
  
  Note the namespace you see:
  
  ```
  Authenticating with the IBM Containers registry host registry.ng.bluemix.net...
  OK
  You are authenticated with the IBM Containers registry.
  Your organization's private Bluemix registry: registry.ng.bluemix.net/<your namespace>
  ```

5. Build a Docker image
  
  ```
  docker build -t todolist-couchdb . 
  ```
  
6. Tag the Docker image:

  ```
  docker tag todolist-couchdb registry.ng.bluemix.net/<your namespace>/todolist-couchdb
  ```
  
7. Push the Docker image: 

  ```
  docker push registry.ng.bluemix.net/<your namespace>/todolist-couchdb
  ```
  
8. Create Cloudant service:

  ```
  cf create-service cloudantNoSQLDB Lite TodoListCloudantDatabase
  ```
  
8. Create a new local directory with an `empty.txt` file, then navigate into that directory.
  
8. Create a bridge application:

  ```
   cf push containerbridge -p . -i 1 -d mybluemix.net -k 1M -m 64M --no-hostname --no-manifest --no-route --no-start
  ```
  
8. Bind service to bridge app:

  ```
  cf bind-service containerbridge TodoListCloudantDatabase
  ```
  
8. Create the Docker group:

  ```
  cf ic group create --anti --auto --name todolist-couchdb -n <hostname you want> -d mybluemix.net -p 8090 -m 128 -e "CCS_BIND_APP=containerbridge" registry.ng.bluemix.net/<your namespace>/todolist-couchdb
  ```

### Manually

Bluemix is a hosting platform from IBM that makes it easy to deploy your app to the cloud. Bluemix also provides various popular databases. [Cloudant](https://cloudant.com/) is an offering that is compatible with the CouchDB database, but provides additional features. You can use Cloudant with your deployed TodoList-CouchDB application.

1. Get an account for [Bluemix](https://console.ng.bluemix.net/registration/)

2. Download and install the [Cloud Foundry tools](https://new-console.ng.bluemix.net/docs/starters/install_cli.html):

    ```
    cf api https://api.ng.bluemix.net
    cf login
    ```

    Be sure to run this in the directory where the manifest.yml file is located.

2. Create your Cloudant Service

  ```
  cf create-service cloudantNoSQLDB Lite TodoListCloudantDatabase
  ```

3. Run `cf push`   

    ***Note** This step will take 3-5 minutes

    ```
    1 of 1 instances running 

    App started
    ```

4. Get the credential information:

   ```
   cf env TodoListCloudantApp
   ```
   
   Note you will see something similar to the following, note the hostname, username, and password:
   
   ```json
   "VCAP_SERVICES": {
  "cloudantNoSQLDB": [
   {
    "credentials": {
     "host": "465ed079-35a8-4731-9425-911843621d7c-bluemix.cloudant.com",
     "password": "<password is here>",
     "port": 443,
     "url": "https://465ed079-35a8-4731-9425-911843621d7c-bluemix:efe561fc02805bcb1e2b013dea4c928942951d31cd74cb2e01df3814751d9f45@465ed079-35a8-4731-9425-911843621d7c-bluemix.cloudant.com",
     "username": "<username is here>"
    },
    ```

5. Setup your database

    Run `cf env` or use the Bluemix dashboard to discover the hostname, username, and password. Run the setup script, passing
    in these variables through command line arguments

    ```bash
    cd Database
    ./setup.sh BLUEMIX_DATABASE_HOST USERNAME PASSWORD
    ```

    For example,
    ```
    ./setup.sh https://1e2e6460-4090-4e6d-8d37-70f308ae2155-bluemix.cloudant.com:443  \
                 1e2e6460-4090-4e6d-8d37-70f308ae2155-bluemix \
                 somepassword
    ```
  
## Privacy Notice
This Swift application includes code to track deployments to [IBM Bluemix](https://www.bluemix.net/) and other Cloud Foundry platforms. The following information is sent to a [Deployment Tracker](https://github.com/IBM-Bluemix/cf-deployment-tracker-service) service on each deployment:

* Swift project code version (if provided)
* Swift project repository URL
* Application Name (`application_name`)
* Space ID (`space_id`)
* Application Version (`application_version`)
* Application URIs (`application_uris`)
* Labels of bound services
* Number of instances for each bound service and associated plan information

This data is collected from the parameters of the `CloudFoundryDeploymentTracker`, the `VCAP_APPLICATION` and `VCAP_SERVICES` environment variables in IBM Bluemix and other Cloud Foundry platforms. This data is used by IBM to track metrics around deployments of sample applications to IBM Bluemix to measure the usefulness of our examples, so that we can continuously improve the content we offer to you. Only deployments of sample applications that include code to ping the Deployment Tracker service will be tracked.

### Disabling Deployment Tracking
Deployment tracking can be disabled by removing the following line from `main.swift`:

    CloudFoundryDeploymentTracker(repositoryURL: "https://github.com/IBM-Swift/TodoList-CouchDB.git").track()
  
## License

Copyright 2016 IBM

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
