#!/bin/bash

URL="http://repo.services.aws.bqreaders.local/nexus/internal/metrics"
USER="admin"
PASS="c0rch0l1s!"

watch "curl -s -X GET --user \"${USER}:${PASS}\" ${URL} | python -m json.tool"
