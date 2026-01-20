#!/bin/bash
set -ex
export DOCKER_BUILDKIT=1
docker build --progress=plain --no-cache -t lvxj11/erpnext:v16 .
set +ex
exit 0
