#!/bin/bash
set -ex
export DOCKER_BUILDKIT=1
# docker build --progress=plain --no-cache -t lvxj11/erpnext:v15 .
docker buildx build --progress=plain --target test .
set +ex
exit 0
