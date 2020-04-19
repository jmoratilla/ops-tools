#!/bin/bash

zoneid="31ac8fab221b5763427732625aa3134c"
today=`date +%Y-%m-%d`

block_ip() {

   target=$1

   curl -X POST "https://api.cloudflare.com/client/v4/zones/${zoneid}/firewall/access_rules/rules" \
   -H "X-Auth-Email: ${CLOUDFLARE_ACCOUNT}" \
   -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
   -H "Content-Type: application/json" \
   --data "{\"mode\":\"block\",\"configuration\":{\"target\":\"ip\",\"value\":\"${target}\"},\"notes\":\"This rule is on because of an event that occured on date ${today}\"}"

   echo
}

IFS=' '

for item in $*; do
    echo "blocking $item"
    block_ip "$item"
done
