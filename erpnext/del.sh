#！/bin/bash
#删除容器服务
docker-compose stop
docker-compose rm -f
#清理容器卷
docker volume prune -f
