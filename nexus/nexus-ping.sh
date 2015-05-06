#!/bin/bash

URL="http://repo.services.aws.bqreaders.local/nexus/internal/ping"
USER="admin"
PASS="c0rch0l1s!"

curl -s -X GET --user "${USER}:${PASS}" ${URL}
