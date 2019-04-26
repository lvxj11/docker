#!/bin/bash
#初始化数据脚本，请将信息修改为自己的！！！
HOSTNAME="127.0.0.1"      #数据库管理信息
PORT="3306"
ADMINNAME="root"
ADMINPW="123456"
USERNAME="user"             #数据库用户信息
USERPW="123456"
DBNAME="mcerpv8"                 #数据库名称
VOLDIR="/mcerpv8"     #你存放PSI的目录位置

#修改PSI中的数据库配置
sed -i "/$db['default']['hostname']/c\$db['default']['hostname'] = '${HOSTNAME}';" /var/www/html/application/config/database.php
sed -i "/$db['default']['username']/c\$db['default']['username'] = '${USERNAME}';" /var/www/html/application/config/database.php
sed -i "/$db['default']['password']/c\$db['default']['password'] = '${USERPW}';" /var/www/html/application/config/database.php
sed -i "/$db['default']['database']/c\$db['default']['database'] = '${DBNAME}';" /var/www/html/application/config/database.php

echo '数据库配置完成请访问网站测试。'
