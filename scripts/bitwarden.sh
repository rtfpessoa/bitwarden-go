#!/usr/bin/env bash
set -e

cat << "EOF"
 _     _ _                         _
| |__ (_) |___      ____ _ _ __ __| | ___ _ __
| '_ \| | __\ \ /\ / / _` | '__/ _` |/ _ \ '_ \
| |_) | | |_ \ V  V / (_| | | | (_| |  __/ | | |
|_.__/|_|\__| \_/\_/ \__,_|_|  \__,_|\___|_| |_|

EOF

cat << EOF
Open source password management solutions
Copyright 2015-$(date +'%Y'), 8bit Solutions LLC
https://bitwarden.com, https://github.com/bitwarden
Go: https://github.com/rtfpessoa/bitwarden-go

===================================================

EOF

docker --version
docker-compose --version

echo ""

# Setup

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=`basename "$0"`
SCRIPT_PATH="$DIR/$SCRIPT_NAME"
OUTPUT="$DIR/bwdata"
if [ $# -eq 2 ]
then
    OUTPUT=$2
fi

SCRIPTS_DIR="$OUTPUT/scripts"
GITHUB_BASE_URL="https://raw.githubusercontent.com/rtfpessoa/bitwarden-go/master"
CORE_VERSION="1.14.1"
WEB_VERSION="1.20.1"
API_VERSION="dev"

# Functions

function downloadSelf() {
    curl -s -o ${SCRIPT_PATH} ${GITHUB_BASE_URL}/scripts/bitwarden.sh
    chmod u+x ${SCRIPT_PATH}
}

function downloadInstall() {
    if [ ! -d "$SCRIPTS_DIR" ]
    then
        mkdir ${SCRIPTS_DIR}
    fi
    curl -s -o ${SCRIPTS_DIR}/install.sh ${GITHUB_BASE_URL}/scripts/install.sh
    chmod u+x ${SCRIPTS_DIR}/install.sh
}

function downloadRunFile() {
    if [ ! -d "$SCRIPTS_DIR" ]
    then
        mkdir ${SCRIPTS_DIR}
    fi
    curl -s -o ${SCRIPTS_DIR}/run.sh ${GITHUB_BASE_URL}/scripts/run.sh
    chmod u+x ${SCRIPTS_DIR}/run.sh
}

function checkOutputDirExists() {
    if [ ! -d "$OUTPUT" ]
    then
        echo "Cannot find a bitwarden installation at $OUTPUT."
        exit 1
    fi
}

function checkOutputDirNotExists() {
    if [ -d "$OUTPUT" ]
    then
        echo "Looks like bitwarden is already installed at $OUTPUT."
        exit 1
    fi
}

# Commands

if [ "$1" == "install" ]
then
    checkOutputDirNotExists
    mkdir ${OUTPUT}
    downloadInstall
    downloadRunFile
    ${SCRIPTS_DIR}/install.sh ${OUTPUT} ${CORE_VERSION} ${WEB_VERSION} ${API_VERSION}
elif [ "$1" == "start" -o "$1" == "restart" ]
then
    checkOutputDirExists
    ${SCRIPTS_DIR}/run.sh restart ${OUTPUT} ${CORE_VERSION} ${WEB_VERSION} ${API_VERSION}
elif [ "$1" == "update" ]
then
    checkOutputDirExists
    downloadRunFile
    ${SCRIPTS_DIR}/run.sh update ${OUTPUT} ${CORE_VERSION} ${WEB_VERSION} ${API_VERSION}
elif [ "$1" == "updatedb" ]
then
    checkOutputDirExists
    ${SCRIPTS_DIR}/run.sh updatedb ${OUTPUT} ${CORE_VERSION} ${WEB_VERSION} ${API_VERSION}
elif [ "$1" == "stop" ]
then
    checkOutputDirExists
    ${SCRIPTS_DIR}/run.sh stop ${OUTPUT} ${CORE_VERSION} ${WEB_VERSION} ${API_VERSION}
elif [ "$1" == "updateself" ]
then
    downloadSelf
    echo "Updated self."
else
    echo "No command found."
fi
