#!/bin/bash

OPENSSL=`which openssl`

if [ "$OPENSSL" == "" ]
then
  echo "openssl command not found.  Exitting..."
  exit 1
fi

$OPENSSL req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -nodes -days 365
