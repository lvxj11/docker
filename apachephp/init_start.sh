#!/bin/bash
if [ -d '/apachephp/' ]; then
	echo "apachephp目录存在"
	if [ ! -d '/apachephp/conf/' -o ! -d '/apachephp/www/' ]; then
    echo "apachephp目录没有初始化，进行初始化..."
    mkdir -p /apachephp/conf
    mv -f /usr/local/apache/conf /apachephp/conf/apache2
    echo "apache2配置迁移完毕。"
    mv -f /usr/local/php/etc /apachephp/conf/php5
    echo "php5配置迁移完毕。"
    echo "开始迁移www目录，此处可能需要较长时间..."
    mv -f /data/www /apachephp
    echo "www目录迁移完毕。"
    ln -s /apachephp/conf/apache2 /usr/local/apache/conf
    ln -s /apachephp/conf/php5 /usr/local/php/etc
    ln -s /apachephp/www /data/www
    echo "链接已建立"
  else
    echo "apachephp目录存在而且已有conf和www目录，检查目录链接是否建立。"
    if [ -L '/data/www' ]; then
    	echo "/data/www目录已是链接，跳过。"
    else
      echo "/data/www目录不是链接开始更换..."
      rm -rf /data/www
      ln -s /apachephp/www /data/www
      echo "更换完成。"
    fi
    if [ -L '/usr/local/apache/conf' ]; then
    	echo "/usr/local/apache/conf目录已是链接，跳过。"
    else
      echo "/usr/local/apache/conf目录不是链接开始更换..."
      rm -rf /usr/local/apache/conf
      ln -s /apachephp/conf/apache2 /usr/local/apache/conf
      echo "更换完成。"
    fi
    if [ -L '/usr/local/php/etc' ]; then
    	echo "/usr/local/php/etc目录已是链接，跳过。"
    else
      echo "/usr/local/php/etc目录不是链接开始更换..."
      rm -rf /usr/local/php/etc
      ln -s /apachephp/conf/php5 /usr/local/php/etc
      echo "更换完成。"
    fi
  fi
else
  echo "/apachephp目录不存在，保持原状。"
fi

/etc/init.d/memcached  start

exec httpd -DFOREGROUND
