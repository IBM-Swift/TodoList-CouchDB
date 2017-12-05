# TodoList CouchDB and Cloudant backend

Todo backend is an example of using the [Kitura](https://github.com/IBM-Swift/Kitura) Swift framework for building a productivity app with a database for storage of tasks.

[![Build Status](https://travis-ci.org/IBM-Swift/TodoList-CouchDB.svg?branch=master)](https://travis-ci.org/IBM-Swift/TodoList-CouchDB)
![](https://img.shields.io/badge/Swift-4.0%20RELEASE-orange.svg)
![](https://img.shields.io/badge/platform-Linux,%20macOS-blue.svg?style=flat)
![IBM Cloud Deployments](https://deployment-tracker.mybluemix.net/stats/9eef579b69ef97de1ef1083552adeea2/badge.svg)

## Quick start for local development:

You can set up your development environment and use Xcode 9 for editing, building, debugging, and testing your server application. To use Xcode, you must use the command line tools for generating an Xcode project.

1. Download [Xcode 9](https://swift.org/download/)
2. Download [CouchDB](http://couchdb.apache.org/) and install

```
brew install couchdb
```

3. Clone the TodoList CouchDB repository

```
git clone https://github.com/IBM-Swift/TodoList-CouchDB
```

4. Generate an Xcode project

```
swift package generate-xcodeproj
```

5. Start CouchDB

```
couchdb
```

6. Run the `Server` target in Xcode and access [http://localhost:8080/](http://localhost:8080/) in your browser to see an empty database.

## Quick start on Linux

To build the project in Linux, you need to first install the Swift 4 toolchain.

1. Install the [Swift 4 RELEASE toolchain](http://www.swift.org)

2. Install CouchDB:

```
sudo apt-get install couchdb
```

3. Clone the repository:

```
git clone https://github.com/IBM-Swift/TodoList-CouchDB
```

4. Compile the project
```
swift build
```

5. Run the server:

```
.build/debug/Server
```

Then access [http://localhost:8080/](http://localhost:8080/) in your browser to see an empty database.

## Deploying to IBM Cloud

### Using the IBM Cloud Tools for Swift

The TodoList for Cloudant is deployable with a graphical user interface. Download:

- [IBM Cloud Application Tools for Swift](http://cloudtools.bluemix.net/)

### Deploy to IBM Cloud Button

You can use this button to deploy TodoList to your IBM Cloud account, all from the browser. The button will create the application, create and bind any services specified in the manifest.yml file and deploy.

[![Deploy to IBM Cloud](https://deployment-tracker.mybluemix.net/stats/9eef579b69ef97de1ef1083552adeea2/button.svg)](https://bluemix.net/deploy?repository=https://github.com/IBM-Swift/TodoList-CouchDB.git)

### Deploying Docker to IBM Cloud Container

As a prerequisite, a cluster must be created on IBM Cloud, this can be done with the following command:

```
./config.sh setup <clusterName> <nameSpace>
```

To verify that the cluster has been created, run the following command and observe the 'state' column. Once it reads 'normal', carry on to the next step.

```
bx cs clusters
```

For the following instructions, we will be using our [Bash Script](config.sh) located in the root directory.
You can attempt to complete the whole process with the following command:

```
./config.sh all <clusterName> <instanceName> <dockerName> <nameSpace>
```

Or, you can follow the step-by-step instructions below.

1. Install the Cloud Foundry CLI tool and the IBM Containers plugin for CF with the following

```
./config.sh install_tools
```

2. Ensure you are logged in with

```
./config.sh login
```

3. Build and run a Docker container with the following

```
./config.sh build <dockerName>
```

To test out created Docker image, use

```
./config.sh run <dockerName>
./config.sh stop <dockerName>
```

4. Push created Docker container to IBM Cloud

```
./config.sh push <dockerName> <nameSpace>
```

5. Deploy the app with

```
./config.sh deploy <appName> <instanceName> <nameSpace>
```

6. Create the database service

```
./config.sh create_db <clusterName> <instanceName> <nameSpace>
```

7. Optionally, if you want to populate your database with some sample data, run the following command with your app URL, username, and password:

```
./config.sh populate_db <appURL> <username> <password>
```

At this point, your app should be deployed! Accessing your apps route should return your todos, which should be `[]` if you did not populate the database.

### Manually

IBM Cloud is a hosting platform from IBM that makes it easy to deploy your app to the cloud. IBM Cloud also provides various popular databases. [Cloudant](https://cloudant.com/) is an offering that is compatible with the CouchDB database, but provides additional features. You can use Cloudant with your deployed TodoList-CouchDB application.

1. Get an account for [IBM Cloud](https://console.ng.bluemix.net/registration/)

2. Download and install the [Cloud Foundry tools](https://new-console.ng.bluemix.net/docs/starters/install_cli.html):

```
cf api https://api.ng.bluemix.net
cf login
```

Be sure to run this in the directory where the manifest.yml file is located.

3. Create your Cloudant Service

```
cf create-service cloudantNoSQLDB Lite TodoListCloudantDatabase
```

4. Push your app

```
cf push
```

***Note** This step will take 3-5 minutes

```
1 of 1 instances running

App started
```

5. Get the credential information:

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
}]}
```

At this point, your app should be deployed! Accessing your apps route should return your todos, which should be `[]` to start.

## Privacy Notice
This Swift application includes code to track deployments to [IBM Cloud](https://www.bluemix.net/) and other Cloud Foundry platforms. The following information is sent to a [Deployment Tracker](https://github.com/IBM-Bluemix/cf-deployment-tracker-service) service on each deployment:

* Swift project code version (if provided)
* Swift project repository URL
* Application Name (`application_name`)
* Space ID (`space_id`)
* Application Version (`application_version`)
* Application URIs (`application_uris`)
* Labels of bound services
* Number of instances for each bound service and associated plan information

This data is collected from the parameters of the `CloudFoundryDeploymentTracker`, the `VCAP_APPLICATION` and `VCAP_SERVICES` environment variables in IBM Cloud and other Cloud Foundry platforms. This data is used by IBM to track metrics around deployments of sample applications to IBM Cloud to measure the usefulness of our examples, so that we can continuously improve the content we offer to you. Only deployments of sample applications that include code to ping the Deployment Tracker service will be tracked.

### Disabling Deployment Tracking
Deployment tracking can be disabled by removing the following line from `main.swift`:

CloudFoundryDeploymentTracker(repositoryURL: "https://github.com/IBM-Swift/TodoList-CouchDB.git").track()

## License

Copyright 2017 IBM

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software :distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

