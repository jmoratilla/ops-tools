#!/bin/bash

PREFIX="XXXXX"
DOMAIN="${PREFIX}.es"

#Default apps
APPS="
${PREFIX}-cam
${PREFIX}-cms
${PREFIX}-comms
${PREFIX}-energy
${PREFIX}-forum
${PREFIX}-pf
${PREFIX}-pf-admin
${PREFIX}-pf-agents
${PREFIX}-pf-backend
${PREFIX}-pixel
${PREFIX}-seguros
${PREFIX}-shortener
"


APPS=${@:-$(echo $APPS | xargs)}


run_or_break () {
    $@ || exit 1
}

ask_continue () {
    reply="Y"
    read -p "Are you sure? [Y/n]" -n 1 -r
    echo

    if [[ ! $reply =~ ^[Yy]$ ]]; then
        echo bye
        exit 1
    fi
}

check_expiration_date () {
    local app
    app=$1
    domain=$(heroku domains -a $app | grep ${DOMAIN} | head -n 1 | awk '{print $1}')

    next_year=$(date -v+1y +%Y)
    openssl_command=`echo | openssl s_client -connect ${app}.herokuapp.com:443 -servername $domain 2>/dev/null | openssl x509 -noout -dates | awk '/notAfter/ {print \$4}'`

    expiration=$openssl_command

    if echo $expiration | grep $next_year > /dev/null; then
        echo "GOOD ($expiration)"
    else
        echo "BAD ($expiration)"
    fi
}

# Begin

# Check heroku toolbelt is installed
if ! which heroku >/dev/null; then
    echo "Please, install the heroku toolbelt"
    exit 1
fi

# Message:
echo "WARNING: before start, let's ensure cert file contains the chain of certificates."

# Ask for path to key
default_key_file="./${PREFIX}.key"
read -p "Enter the path to the key file [${default_key_file}]: " key_file
if [ -z "$key_file" ]
then
    key_file=$default_key_file
fi

# Ask for path to crt
default_cert_file="./${PREFIX}.crt"
read -p "Enter the path to the key file [${default_cert_file}]: " cert_file
if [ -z "$cert_file" ]
then
    cert_file=$default_cert_file
fi

# Check if cert_file contains the CA Authority chain
if [ `grep "BEGIN CERTIFICATE" $cert_file | wc -l` = 1 ]
then
    echo "WARNING: This certificate file only contains one certificate"
fi

echo
ask_continue

if ! ([ -f ${key_file} ] && [ -f ${cert_file} ]); then
    echo "Error: ${key_file} or ${cert_file} don't exist"
    exit 1
fi

if [ -f $HOME/.netrc ]; then
    if ! grep services.admin $HOME/.netrc >/dev/null ; then
        echo "You are not logged in as services.admin"
        echo "Please, use services.admin heroku credentials"
        run_or_break heroku login
    fi
else
    echo "You need to login in heroku. Please, use services.admin heroku credentials"
    run_or_break heroku login
fi

echo "We are going to change SSL certificate for this apps"
echo
for app in $APPS; do
    echo $app
done
echo
ask_continue

for app in $APPS; do
    test -z "$app" && continue
    echo "Updating certificates for $app"
    echo "heroku certs:update ${cert_file} ${key_file} -a $app --confirm $app"
    run_or_break heroku certs:update ${cert_file} ${key_file} -a $app --confirm $app
done

echo waiting 5 seconds to ssl update
sleep 5

for app in $APPS; do
    test -z "$app" && continue
    echo -n "Checking expiration date in certificates for $app: "
    check_expiration_date $app
done

echo "Remember, use the script ssl_expiration_dates.sh to check if certs are already update in every app"
echo "Remember, you need to change manually custom SSL certificates at cloudflare"
