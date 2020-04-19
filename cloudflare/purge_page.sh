#!/bin/bash

if [ "${CLOUDFLARE_ACCOUNT}" == "" ] || [ "${CLOUDFLARE_API_KEY}" == "" ]
then
  echo "CLOUDFLARE_EMAIL or CLOUDFLARE_API_KEY are not defined in the environment."
  echo "You need to have them shared in your environment in order to work."
  echo "Quitting..."
  exit 1
fi

if [ $# -lt 1 ]
then
  echo "Invalid number of arguments.  Syntax: $0 url[ url]"
  exit 1
fi

get_zone() {
  zone=$( echo $1 | perl -ne '$_ =~ m/(kelisto|prestum|quelisto).(\w+)/; print $&' ) 
  case $zone in
    'kelisto.us')
      zone_id='cd664e2e31e6a9fc346548251b331180'
      ;;
    'kelisto.biz')
      zone_id='d98c3fe782098b1b266d6a6351a15530'
      ;;
    'kelisto.es')
      zone_id='31ac8fab221b5763427732625aa3134c'
      ;;
    'kelisto.com')
      zone_id='3efe6980754d70a07e7c5b08ffc06855'
      ;;
    'prestum.es')
      zone_id='e09d1b3a892463fe67a8d9a537c84184'
      ;;
    'quelisto.es')
      zone_id='999fc27243d0e3dcb472da20b13a494b'
      ;;
    *)
      echo "This domain does not exist.  Quitting..."
      exit 1
  esac

}


purge_url() {
  # API v1
  # curl https://www.cloudflare.com/api_json.html \
  #   -d 'a=zone_file_purge' \
  #   -d 'tkn=21e87406757c61d222eabca92204e98830354' \
  #   -d 'email=services.admin@kelisto.es' \
  #   -d 'z=kelisto.es' \
  #   -d "url=$1"

  # New APIv4
  url=$1
  get_zone "${url}"
  
  echo $url
  curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zone_id}/purge_cache" \
  -H "X-Auth-Email: ${CLOUDFLARE_ACCOUNT}" \
  -H "X-Auth-Key: ${CLOUDFLARE_API_KEY}" \
  -H "Content-Type: application/json" \
  --data "{\"files\":[\"${url}\"]}"
  echo
}




IFS=' '

for item in $*; do
    echo "Purging $item"
    purge_url "$item"
done
