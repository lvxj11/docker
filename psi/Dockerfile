#基本image
FROM ubuntu:16.04
#维护者
MAINTAINER lvxj11@126.com

#安装软件
copy init_* /
RUN  /bin/bash -c "set -ex; \
  {\
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial main'; \
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial main'; \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main'; \
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main'; \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial universe'; \
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial universe'; \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe'; \
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates universe'; \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-security main'; \
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main'; \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe'; \
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security universe'; \
  } > /etc/apt/sources.list; \
  apt update; \
  apt upgrade -y; \
  apt install -y git apache2 \
         php7.0 php7.0-fpm php7.0-bz2 \
         php7.0-zip php7.0-curl \
         php7.0-bcmath php7.0-mbstring \
         php7.0-mysql php7.0-xml libapache2-mod-php \
         curl mysql-client; \
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash; \
  source ~/.nvm/nvm.sh; \
  nvm install --lts; \
  npm config set registry https://registry.npm.taobao.org; \
  npm update -g; \
  ln -s ../mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load; \
  ln -s ../mods-available/ssl.load /etc/apache2/mods-enabled/ssl.load; \
  ln -s ../mods-available/ssl.conf /etc/apache2/mods-enabled/ssl.conf; \
  ln -s ../mods-available/socache_shmcb.load /etc/apache2/mods-enabled/socache_shmcb.load; \
  mkdir -p /run/apache2 /var/lock/apache2 /run/php; \
  sed -i '/DocumentRoot \/var\/www\/html/a\	</Directory>' /etc/apache2/sites-available/000-default.conf; \
  sed -i '/DocumentRoot \/var\/www\/html/a\	  Require all granted' /etc/apache2/sites-available/000-default.conf; \
  sed -i '/DocumentRoot \/var\/www\/html/a\	  AllowOverride All' /etc/apache2/sites-available/000-default.conf; \
  sed -i '/DocumentRoot \/var\/www\/html/a\  <Directory /var/www/html/>' /etc/apache2/sites-available/000-default.conf; \
  chmod 755 /init_*.sh; \
  rm -rf /var/www/html; \
  git clone https://gitee.com/crm8000/PSI.git /var/www/html; \
  git clone https://gitee.com/crm8000/PSI_Mobile.git /var/www/PSI_Mobile; \
  cd /var/www/PSI_Mobile; \
  npm install; \
  npm run build; \
  rm -rf /var/www/html/.git; \
  rm -rf /var/www/html/static; \
  rm -rf /var/www/html/m.html; \
  rm -rf /var/www/html/service-worker.js; \
  cp /var/www/PSI_Mobile/dist/index.html /var/www/html/m.html; \
  cp /var/www/PSI_Mobile/dist/service-worker.js /var/www/html; \
  mkdir /var/www/html/static; \
  cp -r /var/www/PSI_Mobile/dist/static/* /var/www/html/static; \
  mv -f /init_dbconf.php /var/www/html/web/Application/Common/Conf/config.php; \
  chmod -R 777 /var/www/html; \
  npm cache clean --force; \
  apt autoclean -y; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html/index.html"

#其它配置
#VOLUME /psivol
EXPOSE 80

#停止信号
STOPSIGNAL SIGTERM

#启动php-fpm7.0和apache2
CMD ["/init_start.sh"]
