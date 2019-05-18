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
  tar -zxvf /init_lamp.tar.gz; \
  chmod -R 755 /lamp; \
  cd /lamp; \
  ./lamp.sh --apache_option 1 --db_option 14 --php_option 1 --php_extensions memcached --kodexplorer_option 1; \
  cd /; \
  mv /data/www/default /data/www/lamp; \
  tar -C /data/www -zxvf /init_app.tar.gz; \
  mv /data/www/vtigercrm7 /data/www/default; \
  mv /data/www/lamp/kod /data/www/default/kod; \
  mv /data/www/lamp /data/www/default/lamp; \
  rm -rf /usr/local/php/etc/php.ini; \
  cp -af /data/www/default/initconfig/php.ini /usr/local/php/etc/php.ini; \
  chmod -R 777 /data/www/default; \
  apt autoclean -y; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* "

#其它配置
#VOLUME /72crm
EXPOSE 80

#停止信号
STOPSIGNAL SIGTERM

#启动php5-fpm和apache2
CMD ["/init_start.sh"]
