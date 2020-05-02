#基本image
FROM ubuntu:18.04
#维护者
MAINTAINER lvxj11@126.com

#安装软件
copy init_* /
RUN  /bin/bash -c "set -ex; \
  cd /; \
  apt update; \
  apt upgrade -y; \
  apt install -y --no-install-recommends \
              wget screen git; \
  chmod 755 /init_*.sh; \
  tar -zxvf /init_lnmp1.6-full.tar.gz; \
  chmod -R 755 /lnmp1.6-full; \
  cd /lnmp1.6-full; \
  LNMP_Auto="y" DBSelect="0" PHPSelect="5" SelectMalloc="1" CheckMirror="n" ./install.sh lnmp; \
  cd /; \
  apt autoclean -y; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /lnmp1.6-full /init_lnmp1.6-full.tar.gz "

#其它配置
#VOLUME /volume
EXPOSE 80

#停止信号
STOPSIGNAL SIGTERM

#启动php5-fpm和apache2
CMD ["nginx", "-g", "daemon off;"]
