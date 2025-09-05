#!/bin/bash

URL="http://repo.services.aws.bqreaders.local/nexus/internal/ping"
USER="xxx"
PASS="xxx"

curl -s -X GET --user "${USER}:${PASS}" ${URL}
