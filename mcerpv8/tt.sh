#!/bin/bash
VOLDIR="mcerpv8"
if [ -d '/${VOLDIR}/' ]; then
	echo "${VOLDIR}目录存在"
	if [ ! -d '/${VOLDIR}/conf/' -o ! -d '/${VOLDIR}/www/' ]; then
    echo "${VOLDIR}目录没有初始化，进行初始化..."

    echo "apache2配置迁移完毕。"

    echo "php配置迁移完毕。"
    echo "开始迁移www目录，此处可能需要较长时间..."

    echo "www目录迁移完毕。"

    echo "链接已建立"
  else
    echo "${VOLDIR}目录存在而且已有conf和www目录，检查目录链接是否建立。"
    if [ -L '/var/www' ]; then
    	echo "/var/www目录已是链接，跳过。"
    else
      echo "/var/www目录不是链接开始更换..."

      echo "更换完成。"
    fi
    if [ -L '/etc/apache2' ]; then
    	echo "/etc/apache2目录已是链接，跳过。"
    else
      echo "/etc/apache2目录不是链接开始更换..."

      echo "更换完成。"
    fi
    if [ -L '/etc/php' ]; then
    	echo "/etc/php目录已是链接，跳过。"
    else
      echo "/etc/php目录不是链接开始更换..."

      echo "更换完成。"
    fi
  fi
else
  echo "${VOLDIR}目录不存在，保持原状。"
fi
echo /${VOLDIR}/