#!/bin/sh
docker run -itd -p 46113:80 -p 46114:443 -p 46115:8000 \
  -v erpnext_tmp:/tmp/.bench \
  --name ubuntu18 ubuntu:18.04
docker cp ./sources.list.ubuntu18 ubuntu18:/etc/apt/sources.list
docker exec -it ubuntu18 apt update
docker exec -it ubuntu18 apt upgrade -y
