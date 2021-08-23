#！/bin/bash
#删除容器
docker stop $1
docker rm $1
#清理容器卷
docker volume prune -f
