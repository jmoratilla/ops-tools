#!/bin/bash
# This scripts changes DNS records for a service
# Syntax: $0 dns_record
# 1. option1
# 2. option2
# Select option (or 'q' to quit):
# Uncomment zone_id_stg to use it for testing (kelisto.us)
#zoneid_stg="cd664e2e31e6a9fc346548251b331180"
set -e

function Tidyup
{
	rm ${tempfile}
    exit 1
}
 
trap Tidyup 1 2 3 15

config_file="https://s3-eu-west-1.amazonaws.com/kelisto-ops/monitoring/failover_config.yml"

zoneid_prod="31ac8fab221b5763427732625aa3134c"
zone_name="kelisto.es"
zone_id=${zoneid_prod}
tempfile="/tmp/.failover_config_$$.yml"



function get_record_id_by_name {
	name=$1

	echo $(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?name=${name}" \
	     -H "X-Auth-Email: ${CLOUDFLARE_ACCOUNT}" \
	     -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
	     -H "Content-Type: application/json"| \
	python -c "import sys, json;obj=json.load(sys.stdin);print(obj[\"result\"][0][\"id\"]);")
}

function get_endpoint_by_name {
	name=$1

	echo $(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?name=${name}" \
	     -H "X-Auth-Email: ${CLOUDFLARE_ACCOUNT}" \
	     -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
	     -H "Content-Type: application/json"| \
	python -c "import sys, json;obj=json.load(sys.stdin);print(obj[\"result\"][0][\"content\"]);")
}


function set_record_id_by_name {
	target_name=$1
	target_id=$(get_record_id_by_name ${target_name}.${zone_name})
	origin=$2

	echo "Zone: ${zone_id}"
	echo "Target: ${target_name}: ${target_id}"
	echo "Origin: ${origin}"

	curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${target_id}" \
	     -H "X-Auth-Email: ${CLOUDFLARE_ACCOUNT}" \
	     -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
	     -H "Content-Type: application/json" \
	     --data "{\"type\": \"CNAME\", \"name\": \"${target_name}\", \"content\": \"${origin}\", \"proxied\": true}" | \
	python -m json.tool

}

# stolen from https://gist.github.com/pkuczynski/8665367: reads a yaml set with 2 spaces.
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function get_config_file {
	echo "Trying to download file: ${config_file}"
	# check if tempfile exist previously
	if [ -f ${tempfile} ]
	then
		echo "Error: ${tempfile} exists.  Check it and delete it before continue."
		echo "Quitting..."
		exit 0
	fi
	
	curl -s -X GET -o ${tempfile} ${config_file}

   	# read yaml file
	eval $(parse_yaml ${tempfile} "config_")
	echo "Done."
}

echo "Starting..."

# Parse arguments
if [ "$#" != "1" ]
then
	echo "Error: invalid number of arguments."
	echo "Syntax: $0 {www|comunicacion|energia|seguros|finanzas|finanzas-agentes|finanzas-backend}"
	exit 1
fi

# Get Config from S3
get_config_file


# Main loop
echo "Current endpoint for ${1} is: $(get_endpoint_by_name ${1}.${zone_name})"
echo

endpoint=""

select PROVIDER in "production" "failover";
do
    case $PROVIDER in
        "production")
			endpoint="config_${1}_production"
            break
            ;;
        "failover")
			endpoint="config_${1}_failover"
            break
            ;;
        *)
            echo "Not valid"
            ;;
    esac
done

# Perform the action
echo "I'm going to execute the following: set origin of ${1}.${zone_name} as ${!endpoint}."
echo "Are you sure?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) set_record_id_by_name $1 ${!endpoint}; break;;
        No ) exit;;
    esac
done

# Ok, let's review what we have done
echo "Last Check: Current endpoint for ${1} is: $(get_endpoint_by_name ${1}.${zone_name})"

# Tyding up
rm ${tempfile}
exit 0
