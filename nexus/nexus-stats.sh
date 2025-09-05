#!/bin/bash

URL="http://repo.services.aws.bqreaders.local/nexus/internal/metrics"
USER="xxx"
PASS="xxx"

watch "curl -s -X GET --user \"${USER}:${PASS}\" ${URL} | python -m json.tool"
