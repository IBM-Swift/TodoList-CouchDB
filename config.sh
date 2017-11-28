#!/bin/bash
#------------------------------------------------------------
# Script: config.sh
# Author: Swift@IBM
# -----------------------------------------------------------

VERSION="1.0"
BUILD_DIR=".build-linux"
BRIDGE_APP_NAME="containerbridge"
DATABASE_NAME="TodoListCloudantDatabase"
REGISTRY_URL="registry.eu-gb.bluemix.net"
DATABASE_TYPE="cloudantNoSQLDB"
DATABASE_LEVEL="Lite"
INSTANCE_NAME="todolist-couchdb"
NAME_SPACE="todolist_space"
LOGIN_URL="api.eu-gb.bluemix.net"

function help {
  cat <<-!!EOF
	  Usage: $CMD [ build | run | push-docker ] [arguments...]

	  Where:
	    install-tools                                   Installs necessary tools for config, like Cloud Foundry CLI
    config-cli                                      Sets up and configures necessary CLI tools
	    login                                           Logs into Bluemix and Container APIs
    setup <clusterName>                             Sets up the clusters
	    build                                           Builds Docker container from Dockerfile
    run <imageName>                                 Runs Docker container, ensuring it was built properly
	    stop <imageName>                                Stops Docker container, if running
	    push-docker                                     Tags and pushes Docker container to IBM Cloud
	    create-db <clusterName> <instanceName>          Creates database service
	    deploy                                          Binds everything together (app, db, container) through container group
	    populate-db	<appURL> <username> <password>      Populates database with initial data
	    delete <clusterName> <instanceName>             Delete the created service and cluster if possible
	    all <clusterName> <instanceName>                Combines all necessary commands to deploy an app to IBM Cloud in a Docker container.
!!EOF
}

install-tools () {
	curl -sL https://ibm.biz/idt-installer | bash
    bx plugin install container-service -r Bluemix
}

config-cli () {
    printf "Installing Kubernetes CLI...\n"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/darwin/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    printf "\nInstalling IBM Cloud Container Service plugin\n"
    bx plugin install container-registry -r Bluemix
    bx plugin list
}

login () {
	echo "Setting api and login tools."
	bx login -a $LOGIN_URL
    bx target --cf
}

setup () {
    if [ -z "$1" ]
    then
        echo "Error: setup failed, cluster name not provided."
    return
    fi

    bx cr login
    bx cr namespace-add $NAME_SPACE
    bx cs workers $1
    bx cs cluster-config $1 --export
}

buildDocker () {
	docker build -t $REGISTRY_URL/$NAME_SPACE/$INSTANCE_NAME .
}

runDocker () {
    if [ -z "$1" ]
    then
        echo "Error: run failed, docker image name not provided."
        return
    fi

    docker run --name $1 -d -p 8080:8080 $1
}

stopDocker () {
	if [ -z "$1" ]
	then
		echo "Error: clean failed, docker image name not provided."
		return
	fi

	docker rm -fv $1 || true
}

pushDocker () {
    bx cr login
	docker push $REGISTRY_URL/$NAME_SPACE/$INSTANCE_NAME
    bx cr images
}

deployContainer () {
    kubectl run todo-deployment --image=$REGISTRY_URL/$NAME_SPACE/$INSTANCE_NAME
    kubectl expose deployment/todo-deployment --type=NodePort --port=8080 --name=todo-service --target-port=8080
}

createDatabase () {
	if [ -z "$1" ] || [ -z "$2" ]
	then
		echo "Error: Creating bridge application failed, cluster name and service instance name not provided."
		return
	fi

    bx service create cloudantNoSQLDB Lite $2
    bx cs cluster-service-bind $1 $NAME_SPACE $2
}

populateDB () {
	if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
	then
		echo "Error: Could not populate db with sample data. App URL, username, and password not provided."
		return
	fi

    curl -u $2:$3 -X PUT -H "Content-Type: application/json" -d '{ "title": "Wash the car", "order": 0, "completed": false }' $1
    curl -u $2:$3 -X PUT -H "Content-Type: application/json" -d '{ "title": "Walk the dog", "order": 2, "completed": true }' $1
    curl -u $2:$3 -X PUT -H "Content-Type: application/json" -d '{ "title": "Clean the gutters", "order": 1, "completed": false }' $1
}

delete () {
	if [ -z "$1" ] || [ -z "$2" ]
	then
		echo "Error: Could not delete container group and service, cluster name and service instance name not provided."
		return
	fi

    bx cs cluster-service-unbind $1 $NAME_SPACE $2
    bx cs cluster-rm $1
}

all () {
	if [ -z "$1" ] || [ -z "$2" ]
	then
		echo "Error: Could not complete entire deployment process, cluster name and service instance name not provided."
		return
	fi

    install-tools
    config-cli
	login
    setup $1
	buildDocker
	pushDocker
    deployContainer
	createDatabase $1 $2
}

#----------------------------------------------------------
# MAIN
# ---------------------------------------------------------

ACTION="$1"

[[ -z $ACTION ]] && help && exit 0

# Initialize the SwiftEnv project environment
eval "$(swiftenv init -)"


case $ACTION in
"install-tools")		 install-tools;;
"config-cli")            config-cli;;
"login")                 login;;
"setup")                 setup "$2";;
"build")				 buildDocker;;
"run")                   runDocker "$2";;
"stop")				     stopDocker "$2";;
"push-docker")			 pushDocker;;
"create-db")		     createDatabase "$2" "$3";;
"deploy")				 deployContainer;;
"populate-db")			 populateDB "$2" "$3" "$4";;
"delete")				 delete "$2" "$3";;
"all")					 all "$2" "$3";;
*)                       help;;
esac
