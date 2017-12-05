#!/usr/bin/env bash
set -e

# Setup

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OUTPUT_DIR="../."
if [ $# -gt 1 ]
then
    OUTPUT_DIR=$2
fi

CORE_VERSION="latest"
if [ $# -gt 2 ]
then
    CORE_VERSION=$3
fi

WEB_VERSION="latest"
if [ $# -gt 3 ]
then
    WEB_VERSION=$4
fi

API_VERSION="dev"
if [ $# -gt 4 ]
then
    API_VERSION=$5
fi

DOCKER_DIR="$OUTPUT_DIR/docker"

# Functions

function dockerComposeUp() {
    docker-compose -f ${DOCKER_DIR}/docker-compose.yml up -d
}

function dockerComposeDown() {
    docker-compose -f ${DOCKER_DIR}/docker-compose.yml down
}

function dockerComposePull() {
    docker-compose -f ${DOCKER_DIR}/docker-compose.yml pull
}

function dockerPrune() {
    docker image prune -f
}

function updateLetsEncrypt() {
    if [ -d "${OUTPUT_DIR}/letsencrypt/live" ]
    then
        docker pull certbot/certbot
        docker run -it --rm --name certbot -p 443:443 -p 80:80 -v ${OUTPUT_DIR}/letsencrypt:/etc/letsencrypt/ certbot/certbot \
            renew --logs-dir /etc/letsencrypt/logs
    fi
}

function updateDatabase() {
    # TODO: this should be a db update
    echo "Database update complete"
}

function update() {
    pullSetup
    # TODO: this should be an update
}

function printEnvironment() {
    pullSetup
    # TODO: this should print the env
}

function restart() {
    dockerComposeDown
    dockerComposePull
    updateLetsEncrypt
    dockerComposeUp
    dockerPrune
    printEnvironment
}

function pullSetup() {
    docker pull rtfpessoa/bitwarden-go:${API_VERSION}
}

# Commands

if [ "$1" == "start" -o "$1" == "restart" ]
then
    restart
elif [ "$1" == "pull" ]
then
    dockerComposePull
elif [ "$1" == "stop" ]
then
    dockerComposeDown
elif [ "$1" == "updatedb" ]
then
    updateDatabase
elif [ "$1" == "update" ]
then
    dockerComposeDown
    update
    restart
    updateDatabase
fi
