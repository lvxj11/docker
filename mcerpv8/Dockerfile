#基本image
FROM ubuntu:14.04
#维护者
MAINTAINER lvxj11@126.com

#安装软件
copy init_* /
RUN  /bin/bash -c "set -ex; \
  apt update; \
  apt upgrade -y; \
  apt install -y --no-install-recommends \
              apache2 \
              php5 php5-fpm libapache2-mod-php5 php5-mysql php5-mysqli \
              php5-curl php5-sqlite php5-xsl
              mysql-client; \
  ln -s ../mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load; \
  ln -s ../mods-available/ssl.load /etc/apache2/mods-enabled/ssl.load; \
  ln -s ../mods-available/ssl.conf /etc/apache2/mods-enabled/ssl.conf; \
  ln -s ../mods-available/socache_shmcb.load /etc/apache2/mods-enabled/socache_shmcb.load; \
  mkdir -p /run/apache2 /var/lock/apache2; \
  sed -i '/DocumentRoot \/var\/www\/html/a\	</Directory>' /etc/apache2/sites-available/000-default.conf; \
  sed -i '/DocumentRoot \/var\/www\/html/a\	  Require all granted' /etc/apache2/sites-available/000-default.conf; \
  sed -i '/DocumentRoot \/var\/www\/html/a\	  AllowOverride All' /etc/apache2/sites-available/000-default.conf; \
  sed -i '/DocumentRoot \/var\/www\/html/a\  <Directory /var/www/html/>' /etc/apache2/sites-available/000-default.conf; \
  chmod 755 /init_*.sh; \
  rm -rf /var/www/html/*; \
  tar -C /var/www/html -zxvf /init_app.tar.gz; \
  chmod -R 777 /var/www/html; \
  locale-gen zh_CN.UTF-8; \
  rm -rf /init_app.tar.gz; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html/index.html"

#其它配置
#VOLUME /mcerpv8
EXPOSE 80

#停止信号
STOPSIGNAL SIGTERM

#启动php5-fpm和apache2
CMD ["/init_start.sh"]
