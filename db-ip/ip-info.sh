#!/bin/bash

# This script takes an IP Address as argument and returns a JSON with all the
# info about the IP

if [ "$1" == "" ]
then
    echo "Syntax error:  $0 <IPAddress>"
    exit 1
fi

TARGET=$1

curl http://api.db-ip.com/v2/free/${TARGET}
