#!/bin/bash

if [ "$#" != "2" ]; then
  echo "Syntax: $0 production|staging service"
  exit 1
fi

payload_file=/tmp/.payload

environment=$1
service=$2

case $environment in 
  'production')
    url_production_1="https://${service}.kelisto.es/"
    url_production_2="https://${service}.kelisto.es/*"
    cloudflare_api="https://api.cloudflare.com/client/v4/zones/31ac8fab221b5763427732625aa3134c/pagerules"
    ;;
  'staging')
    url_production_1="https://${service}.kelisto.us/"
    url_production_2="https://${service}.kelisto.us/*"
    cloudflare_api="https://api.cloudflare.com/client/v4/zones/cd664e2e31e6a9fc346548251b331180/pagerules"
    ;;
  *)
    echo "Error: only 'production' or 'staging' are supported"
    exit 1
  ;;
esac

url_failover_1="https://${service}.kelisto.biz/"
url_failover_2="https://${service}.kelisto.biz/\$1"

function enable_forwarding {
  from=$1
  to=$2

  cat > $payload_file <<EOF 
  { 
    "targets": [
      {
        "target": "url",
        "constraint": {
          "operator": "matches",
          "value": "${from}"
          }
      }],
      "actions": [
        {
          "id": "forwarding_url",
          "value": {
            "url": "${to}",
            "status_code": 302
          }
      }],
      "priority": 1,
      "status": "active"
  }
EOF

  echo -n "Redir: from ${from} to ${to} => "
  response=$(curl -s -X POST "$cloudflare_api" \
    -H "X-Auth-Email: $CLOUDFLARE_ACCOUNT" \
    -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
    -H "Content-Type: application/json" \
    --data @$payload_file)
  if [ "$?" == "0" ]; then
    echo "Rule id: $(echo $response  | perl -n -e '/(?<id>\w+)?",/; print $+{id}')"
    rm $payload_file
  else
    echo "Error! review the cloudflare response and the file $payload_file"
    echo $response
  fi
}

enable_forwarding $url_production_1 $url_failover_1
enable_forwarding $url_production_2 $url_failover_2


