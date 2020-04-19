#!/bin/bash

PREFIX="XXXX"
DOMAIN="${PREFIX}.es"

# staging does not have ssl
APPS=`heroku apps | awk '/^\${PREFIX}/ {print $1}' | grep -v staging`

if [ -n "$1" ]; then
    domain=$1
    echo | openssl s_client -connect $domain:443 2>/dev/null | openssl x509 -noout -dates
    exit 0
fi

check_expiration_date () {
    local app
    app=$1
    domain=$(heroku domains -a $app | grep ${DOMAIN} | head -n 1 | awk '{print $1}')

    year=$(date +%Y)

    openssl_command=`echo | openssl s_client -connect ${app}.herokuapp.com:443 -servername $domain 2>/dev/null | openssl x509 -noout -dates | awk '/notAfter/ {print \$4}'`

    expiration=$openssl_command

    if [ $((expiration - year)) > 0 ]; then
        echo "GOOD ($expiration)"
    else
        echo "BAD ($expiration)"
    fi
}


for app in $APPS; do
    test -z "$app" && continue
    echo -n "Checking expiration date in certificates for $app: "
    check_expiration_date $app
done

