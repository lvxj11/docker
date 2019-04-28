#基本image
FROM ubuntu:16.04
#维护者
MAINTAINER lvxj11@126.com

#安装软件
copy init_* /
RUN  /bin/bash -c "set -ex; \
  apt update; \
  apt upgrade -y; \
  apt install -y --no-install-recommends \
              wget screen git; \
  chmod 755 /init_*.sh; \
  mkdir /lamp; \
  tar -C /lamp -zxvf /init_lamp.tar.gz; \
  cd /lamp; \
  ./lamp.sh auto; \
  cd /; \
  mv /data/www/default/index.html /data/www/default/lamp_en.html; \
  mv /data/www/default/index_cn.html /data/www/default/lamp.html; \
  tar -C /data/www/default -zxvf /init_app.tar.gz; \
  chmod -R 777 /data/www/default; \
  apt autoclean -y; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html/index.html"

#其它配置
#VOLUME /mcerpv8
EXPOSE 80

#停止信号
STOPSIGNAL SIGTERM

#启动php5-fpm和apache2
CMD ["/init_start.sh"]
