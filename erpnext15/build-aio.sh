#!/bin/bash

# 获取apps.json的base64
export APPS_JSON_BASE64=$(base64 -w 0 ./aiofile/apps.json)

case $1 in
    "test")
        docker build \
            --build-arg=APPS_JSON_BASE64=${APPS_JSON_BASE64} \
            --target=test \
            --progress=plain \
            --file=Containerfile-aio .
        ;;
    *)
        docker build \
            --build-arg=APPS_JSON_BASE64=${APPS_JSON_BASE64} \
            --tag=lvxj11/erpnext:v15 \
            --target=erpnext_aio \
            --progress=plain \
            --file=Containerfile-aio .
        ;;
esac
