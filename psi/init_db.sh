#!/bin/bash
set -e
#初始化数据脚本，请将信息修改为自己的！！！
#此操作会初始化数据库，原有可能信息会丢失，请谨慎执行！！
HOSTNAME="127.0.0.1"      #数据库管理信息
PORT="3306"
ADMINNAME="root"
ADMINPW="123456"
USERNAME="psier"             #数据库用户信息
USERPW="123456"
DBNAME="psi"                 #数据库名称
PSIDIR="你的PSI目录位置"     #你存放PSI的目录位置

#判断数据库是否存在，如不存在建库并给用户赋权。
DBEXISTS=`mysql -h${HOSTNAME}  -P${PORT}  -u${ADMINNAME} -p${ADMINPW} -e "show databases like '${DBNAME}';"`
if [ "${DBEXISTS}" = "" ]; then
	echo '数据库不存在，开始初始化数据库...'
  mysql -h${HOSTNAME}  -P${PORT}  -u${ADMINNAME} -p${ADMINPW} \
        -e "create database ${DBNAME} character set utf8mb4;"
  mysql -h${HOSTNAME}  -P${PORT}  -u${ADMINNAME} -p${ADMINPW} \
        -e "grant all on ${DBNAME}.* to '${USERNAME}'@'%' identified by '${USERPW}';"
  #执行数据库导入
  mysql -u${USERNAME} -h${HOSTNAME} -p${USERPW} ${DBNAME} < ${PSIDIR}'/doc/99 SQL/01CreateTables.sql'
  mysql -u${USERNAME} -h${HOSTNAME} -p${USERPW} ${DBNAME} < ${PSIDIR}'/doc/99 SQL/02InsertInitData.sql'
  #演示数据，正式使用不要导入。
  #mysql -u${USERNAME} -h${HOSTNAME} -p${USERPW} ${DBNAME} < ${PSIDIR}'/doc/99 SQL/99psi_demo_data.sql'
else
  echo '数据库已存在。只更新配置不初始化数据库。'
fi

#修改PSI中的数据库配置
sed -i "/DB_HOST/c\    'DB_HOST' => '${HOSTNAME}', // 服务器地址" /var/www/html/web/Application/Common/Conf/config.php
sed -i "/DB_PORT/c\    'DB_PORT' => '${PORT}', // 服务器地址" /var/www/html/web/Application/Common/Conf/config.php
sed -i "/DB_NAME/c\    'DB_NAME' => '${DBNAME}', // 服务器地址" /var/www/html/web/Application/Common/Conf/config.php
sed -i "/DB_USER/c\    'DB_USER' => '${USERNAME}', // 服务器地址" /var/www/html/web/Application/Common/Conf/config.php
sed -i "/DB_PWD/c\    'DB_PWD' => '${USERPW}', // 服务器地址" /var/www/html/web/Application/Common/Conf/config.php

echo '数据库配置完成请访问网站测试。'