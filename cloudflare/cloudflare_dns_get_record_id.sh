#!/bin/bash
# This script gets the list of DNS records for a zone.
zoneid_stg="cd664e2e31e6a9fc346548251b331180"
zoneid_prod="31ac8fab221b5763427732625aa3134c"

zoneid=$zoneid_prod
get_record_id_by_name() {
	name=$1
	echo "Zone: ${zoneid}"
	echo "Name: ${name}"

	curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records?name=${name}" \
	     -H "X-Auth-Email: ${CLOUDFLARE_ACCOUNT}" \
	     -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
	     -H "Content-Type: application/json" | \
	python -m json.tool


}


get_record_id_by_name $1
