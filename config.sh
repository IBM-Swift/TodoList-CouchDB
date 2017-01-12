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

function help {
  cat <<-!!EOF
	  Usage: $CMD [ build | run | push-docker ] [arguments...]

	  Where:
	    install-tools				Installs necessary tools for config, like Cloud Foundry CLI
	    login					Logs into Bluemix and Container APIs
	    build <imageName>          			Builds Docker container from Dockerfile
	    run   <imageName>         			Runs Docker container, ensuring it was built properly
	    stop  <imageName> 				Stops Docker container, if running
	    push-docker <imageName>			Tags and pushes Docker container to Bluemix
	    create-bridge				Creates empty bridge application
	    create-db				        Creates database service and binds to bridge
	    deploy <imageName>				Binds everything together (app, db, container) through container group
	    populate-db					Populates database with initial data
	    delete <imageName>				Delete the group container and deletes created service if possible
	    all <imageName>                 		Combines all necessary commands to deploy an app to Bluemix in a Docker container.
!!EOF
}

install-tools () {
	brew tap cloudfoundry/tap
	brew install cf-cli
	cf install-plugin https://static-ice.ng.bluemix.net/ibm-containers-mac
}

login () {
	echo "Setting api and login tools."
	cf api https://api.ng.bluemix.net
	cf login
	cf ic login
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
	docker run --name $1 -d -p 8090:8090 $1
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
	if [ -z "$1" ] || [ -z $REGISTRY_URL ]
	then
		echo "Error: Pushing Docker container to Bluemix failed, missing variables."
		return
	fi
	echo "Tagging and pushing docker container..."
    namespace=$(cf ic namespace get)
	docker tag $1 $REGISTRY_URL/$namespace/$1
	docker push $REGISTRY_URL/$namespace/$1
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
	-p 8090 \
	-n $hostname \
	-e "CCS_BIND_APP="$BRIDGE_APP_NAME \
	-d mybluemix.net $REGISTRY_URL/$namespace/$1
}

populateDB () {
	if [ -z $BRIDGE_APP_NAME ]
	then
		echo "Error: Could not deploy container to Bluemix, missing variables."
		return
	fi
	rawValue=$(cf env $BRIDGE_APP_NAME | grep 'uri_cli' | awk -F: '{print $2}')
	commanToRun=$(echo $rawValue | tr -d '\' | sed -e 's/^"//' -e 's/"$//')
	
	password=$(cf env $BRIDGE_APP_NAME | grep 'postgres://' | sed -e 's/@bluemix.*$//' -e 's/^.*admin://')
	eval PGPASSWORD=$password $commanToRun < Database/schema.sql
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

	login
	build $1
	push-docker $1
	create-bridge
	create-db
	deploy $1
	populate-db
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
"login")                 login;;
"build")				 buildDocker "$2";;
"run")					 runDocker "$2";;
"stop")				     stopDocker "$2";;
"push-docker")			 pushDocker "$2";;
"create-bridge")		 createBridge;;
"create-db")		     createDatabase;;
"deploy")				 deployContainer "$2";;
"populate-db")			 populateDB;;
"delete")				 delete "$2";;
"all")					 all "$2";;
*)                       help;;
esac