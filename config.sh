#!/bin/bash
#------------------------------------------------------------
# Script: config.sh
# Author: Swift@IBM
# -----------------------------------------------------------

VERSION="1.0"
BUILD_DIR=".build-linux"
BRIDGE_APP_NAME="containerbridge"
DATABASE_NAME="TodoListCloudantDatabase"
REGISTRY_URL="registry.ng.bluemix.net"
DATABASE_TYPE="cloudantNoSQLDB"
DATABASE_LEVEL="Lite"
NAME_SPACE="todolist_space"

function help {
  cat <<-!!EOF
	  Usage: $CMD [ build | run | push-docker ] [arguments...]

	  Where:
	    install-tools				Installs necessary tools for config, like Cloud Foundry CLI
        config-cli                  Sets up and configures necessary CLI tools
	    login					Logs into Bluemix and Container APIs
        setup <clusterName>                               Sets up the clusters
	    build <imageName>          			Builds Docker container from Dockerfile
	    run   <imageName>         			Runs Docker container, ensuring it was built properly
	    stop  <imageName> 				Stops Docker container, if running
	    push-docker <imageName>			Tags and pushes Docker container to Bluemix
	    create-bridge				Creates empty bridge application
	    create-db				        Creates database service and binds to bridge
	    deploy <imageName>				Binds everything together (app, db, container) through container group
	    populate-db	<imageName>			Populates database with initial data
	    delete <imageName>				Delete the group container and deletes created service if possible
	    all <imageName>                 		Combines all necessary commands to deploy an app to Bluemix in a Docker container.
!!EOF
}

install-tools () {
	brew tap cloudfoundry/tap
	brew install cf-cli
	cf install-plugin https://static-ice.ng.bluemix.net/ibm-containers-mac
    bx plugin install container-service -r Bluemix
}

config-cli () {
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/darwin/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    bx plugin install container-registry -r Bluemix
    bx plugin list
}

login () {
	echo "Setting api and login tools."
	bx login --sso -a api.eu-gb.bluemix.net
}

setup () {
    if [ -z "$1" ]
    then
        echo "Error: setup failed, cluster name not provided."
    return
    fi
    bx cr namespace-add $NAME_SPACE
    bx cs workers $1
    bx cs cluster-config $1

    MAGENTA='\033[1;35m'
    NC='\033[0m'
    printf "\n${MAGENTA}Copy and paste the command that is displayed in your terminal to set the KUBECONFIG environment variable${NC}\n"
}

buildDocker () {
	if [ -z "$1" ]
	then
		echo "Error: build failed, docker name not provided."
		return
	fi
	docker build -t $1 --force-rm .
}

runDocker () {
	if [ -z "$1" ]
	then
		echo "Error: run failed, docker name not provided."
		return
	fi
	docker run --name $1 -d -p 8080:8080 $1
}

stopDocker () {
	if [ -z "$1" ]
	then
		echo "Error: clean failed, docker name not provided."
		return
	fi
	docker rm -fv $1 || true
}

pushDocker () {
	if [ -z "$1" ] || [ -z $REGISTRY_URL ] || [ -z "$2" ]
	then
		echo "Error: Pushing Docker container to Bluemix failed, missing variables."
		return
	fi
	echo "Tagging and pushing docker container..."
    namespace=$(docker ps --format "{{.Names}}")
    echo "$namespace"
	docker tag $1 $2/$1
	docker push $2/$1
}

createBridge () {
	if [ -z $BRIDGE_APP_NAME ]
	then
		echo "Error: Creating bridge application failed, missing BRIDGE_APP_NAME."
		return
	fi
	mkdir $BRIDGE_APP_NAME
	cd $BRIDGE_APP_NAME
	touch empty.txt
	cf push $BRIDGE_APP_NAME -p . -i 1 -d mybluemix.net -k 1M -m 64M --no-hostname --no-manifest --no-route --no-start
	rm empty.txt
	cd ..
	rm -rf $BRIDGE_APP_NAME
}

createDatabase () {
	if [ -z $DATABASE_TYPE ] || [ -z $DATABASE_LEVEL ] || [ -z $DATABASE_NAME ] || [ -z $BRIDGE_APP_NAME ]
	then
		echo "Error: Creating bridge application failed, missing variables."
		return
	fi
	cf create-service $DATABASE_TYPE $DATABASE_LEVEL $DATABASE_NAME
	cf bind-service $BRIDGE_APP_NAME $DATABASE_NAME
	cf restage $BRIDGE_APP_NAME
}

deployContainer () {
	if [ -z "$1" ] || [ -z $REGISTRY_URL ] || [ -z $BRIDGE_APP_NAME ]
	then
		echo "Error: Could not deploy container to Bluemix, missing variables."
		return
	fi

	namespace=$(cf ic namespace get)
	hostname=$1"-app"

	cf ic group create \
	--anti \
	--auto \
	-m 128 \
	--name $1 \
	-p 8080 \
	-n $hostname \
	-e "CCS_BIND_APP="$BRIDGE_APP_NAME \
	-d mybluemix.net $REGISTRY_URL/$namespace/$1
}

populateDB () {
	if [ -z "$1" ]
	then
		echo "Error: Could not populate db with sample data, missing imageName."
		return
	fi

	appURL="https://"$1"-app.mybluemix.net"
	eval $(curl -X POST -H "Content-Type: application/json" -d '{ "title": "Wash the car", "order": 0, "completed": false }' $appURL)
	eval $(curl -X POST -H "Content-Type: application/json" -d '{ "title": "Walk the dog", "order": 2, "completed": true }' $appURL)
	eval $(curl -X POST -H "Content-Type: application/json" -d '{ "title": "Clean the gutters", "order": 1, "completed": false }' $appURL)
}

delete () {
	if [ -z "$1" ] || [ -z $DATABASE_NAME ] || [ -z $BRIDGE_APP_NAME ]
	then
		echo "Error: Could not delete container group and service, missing variables."
		return
	fi

	cf ic group rm $1
	cf unbind-service $BRIDGE_APP_NAME $DATABASE_NAME
	cf delete-service $DATABASE_NAME
}

all () {
	if [ -z "$1" ]
	then
		echo "Error: Could not complete entire deployment process, missing variables."
		return
	fi

    install-tools
    config-cli
	login
    setup $1
	buildDocker $1
	pushDocker $1
	createBridge
	createDatabase
	deployContainer $1
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
"build")				 buildDocker "$2";;
"run")					 runDocker "$2";;
"stop")				     stopDocker "$2";;
"push-docker")			 pushDocker "$2" "$3";;
"create-bridge")		 createBridge;;
"create-db")		     createDatabase;;
"deploy")				 deployContainer "$2";;
"populate-db")			 populateDB "$2";;
"delete")				 delete "$2";;
"all")					 all "$2";;
*)                       help;;
esac
