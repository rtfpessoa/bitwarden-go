#!/usr/bin/env bash

set -e

OUTPUT_DIR="../."
if [ $# -gt 0 ]
then
    OUTPUT_DIR=$1
fi

CORE_VERSION="latest"
if [ $# -gt 1 ]
then
    CORE_VERSION=$2
fi

WEB_VERSION="latest"
if [ $# -gt 2 ]
then
    WEB_VERSION=$3
fi

API_VERSION="dev"
if [ $# -gt 3 ]
then
    API_VERSION=$4
fi

mkdir -p ${OUTPUT_DIR}

LETS_ENCRYPT="n"
read -p "(!) Enter the domain name for your bitwarden instance (ex. bitwarden.company.com): " DOMAIN

if [ "$DOMAIN" == "" ]
then
    DOMAIN="localhost"
fi

if [ "$DOMAIN" != "localhost" ]
then
    read -p "(!) Do you want to use Let's Encrypt to generate a free SSL certificate? (y/n): " LETS_ENCRYPT

    if [ "$LETS_ENCRYPT" == "y" ]
    then
        read -p "(!) Enter your email address (Let's Encrypt will send you certificate expiration reminders): " EMAIL
        mkdir -p ${OUTPUT_DIR}/letsencrypt
        docker pull certbot/certbot
        docker run -it --rm --name certbot -p 80:80 -v ${OUTPUT_DIR}/letsencrypt:/etc/letsencrypt/ certbot/certbot \
            certonly --standalone --noninteractive  --agree-tos --preferred-challenges http --email ${EMAIL} -d ${DOMAIN} \
            --logs-dir /etc/letsencrypt/logs
    fi
fi

docker pull rtfpessoa/bitwarden-go:${API_VERSION}
docker run -it --rm --name setup -v ${OUTPUT_DIR}:/bitwarden rtfpessoa/bitwarden-go:${API_VERSION} \
    ./setup -o /bitwarden -d ${DOMAIN} -l ${LETS_ENCRYPT} -c ${CORE_VERSION} -w ${WEB_VERSION}  -r ${API_VERSION}

echo ""
echo "Setup complete"
