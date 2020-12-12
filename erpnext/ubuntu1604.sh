#!/bin/sh
docker run -itd -p 46110:80 -p 46111:443 -p 46112:8000 \
  --name ubuntu16 ubuntu:16.04
docker cp ./sources.list.ubuntu16 ubuntu16:/etc/apt/sources.list
docker exec -it ubuntu16 apt update
docker exec -it ubuntu16 apt upgrade -y
