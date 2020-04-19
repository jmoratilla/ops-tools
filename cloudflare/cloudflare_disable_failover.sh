#!/bin/bash

if [ "$#" != "2" ]; then
  echo "Syntax: $0 production|staging rule_id"
  exit 1
fi

environment=$1
rule_id=$2

case $environment in 
  'production')
    cloudflare_api="https://api.cloudflare.com/client/v4/zones/31ac8fab221b5763427732625aa3134c/pagerules"
    ;;
  'staging')
    cloudflare_api="https://api.cloudflare.com/client/v4/zones/cd664e2e31e6a9fc346548251b331180/pagerules"
    ;;
  *)
    echo "Error: only 'production' or 'staging' are supported"
    exit 1
  ;;
esac

cloudflare_api="$cloudflare_api/$rule_id"


# Command to send to Cloudflare
echo "Deleting rule: $rule_id"
curl -X DELETE "$cloudflare_api" \
  -H "X-Auth-Email: $CLOUDFLARE_ACCOUNT" \
  -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
  -H "Content-Type: application/json"

echo ""
