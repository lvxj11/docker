#!/bin/sh
docker run -itd \
  -v MR_tmp:/tmp \
  -v MR_home:/home \
  --name ubuntu18mr ubuntu18mr:t2
