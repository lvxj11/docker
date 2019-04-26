#!/bin/bash
if [ -d '/mcerpv8/' ]; then
	echo "mcerpv8目录存在"
	if [ ! -d '/mcerpv8/conf/' -o ! -d '/mcerpv8/www/' ]; then
    echo "mcerpv8目录没有初始化，进行初始化..."
    mkdir -p /mcerpv8/conf
    mv -f /etc/apache2 /mcerpv8/conf
    echo "apache2配置迁移完毕。"
    mv -f /etc/php5 /mcerpv8/conf
    echo "php5配置迁移完毕。"
    echo "开始迁移www目录，此处可能需要较长时间..."
    mv -f /var/www /mcerpv8
    echo "www目录迁移完毕。"
    ln -s /mcerpv8/conf/apache2 /etc/apache2
    ln -s /mcerpv8/conf/php5 /etc/php5
    ln -s /mcerpv8/www /var/www
    echo "链接已建立"
  else
    echo "mcerpv8目录存在而且已有conf和www目录，检查目录链接是否建立。"
    if [ -L '/var/www' ]; then
    	echo "/var/www目录已是链接，跳过。"
    else
      echo "/var/www目录不是链接开始更换..."
      mv -f /var/www /psibak/wwwbak
      ln -s /mcerpv8/www /var/www
      echo "更换完成。"
    fi
    if [ -L '/etc/apache2' ]; then
    	echo "/etc/apache2目录已是链接，跳过。"
    else
      echo "/etc/apache2目录不是链接开始更换..."
      mv -f /etc/apache2 /psibak/apache2bak
      ln -s /mcerpv8/conf/apache2 /etc/apache2
      echo "更换完成。"
    fi
    if [ -L '/etc/php5' ]; then
    	echo "/etc/php5目录已是链接，跳过。"
    else
      echo "/etc/php5目录不是链接开始更换..."
      mv -f /etc/php5 /psibak/php5bak
      ln -s /mcerpv8/conf/php5 /etc/php5
      echo "更换完成。"
    fi
  fi
else
  echo "mcerpv8目录不存在，保持原状。"
fi
rm -rf /run/apache2/*
rm -rf /run/php5*

php5-fpm
source /etc/apache2/envvars
exec apache2 -DFOREGROUND
