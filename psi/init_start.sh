#!/bin/bash
if [ -d '/psivol/' ]; then
	echo "psivol目录存在"
	if [ ! -d '/psivol/conf/' -o ! -d '/psivol/www/' ]; then
    echo "psivol目录没有初始化，进行初始化..."
    mkdir -p /psivol/conf
    mv -f /etc/apache2 /psivol/conf
    echo "apache2配置迁移完毕。"
    mv -f /etc/php /psivol/conf
    echo "php配置迁移完毕。"
    echo "开始迁移www目录，此处可能需要较长时间..."
    mv -f /var/www /psivol
    echo "www目录迁移完毕。"
    ln -s /psivol/conf/apache2 /etc/apache2
    ln -s /psivol/conf/php /etc/php
    ln -s /psivol/www /var/www
    echo "链接已建立"
  else
    echo "psivol目录存在而且已有conf和www目录，检查目录链接是否建立。"
    if [ -L '/var/www' ]; then
    	echo "/var/www目录已是链接，跳过。"
    else
      echo "/var/www目录不是链接开始更换..."
      mv -f /var/www /psibak/wwwbak
      ln -s /psivol/www /var/www
      echo "更换完成。"
    fi
    if [ -L '/etc/apache2' ]; then
    	echo "/etc/apache2目录已是链接，跳过。"
    else
      echo "/etc/apache2目录不是链接开始更换..."
      mv -f /etc/apache2 /psibak/apache2bak
      ln -s /psivol/conf/apache2 /etc/apache2
      echo "更换完成。"
    fi
    if [ -L '/etc/php' ]; then
    	echo "/etc/php目录已是链接，跳过。"
    else
      echo "/etc/php目录不是链接开始更换..."
      mv -f /etc/php /psibak/phpbak
      ln -s /psivol/conf/php /etc/php
      echo "更换完成。"
    fi
  fi
else
  echo "'/psivol'目录不存在，保持原状。"
fi
rm -rf /run/apache2/*
rm -rf /run/php/*
echo "新建服务需要导入数据库和修改数据库配置，请参考官网：https://gitee.com/crm8000/PSI。"
echo "或参考文档：你的挂载卷/www/heml/doc"
echo "如果升级后需要升级数据库但又找不到菜单请直接访问http://你的主机地址/web/Home/Bizlog一键升级数据库。"
echo "还有不明白的发邮件到：lvxj11@126.com。（本人小白一个，尽力吧）"
php-fpm7.0
source /etc/apache2/envvars
exec apache2 -DFOREGROUND
