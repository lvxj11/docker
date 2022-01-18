#!/bin/bash
set -e
# 修改apt源
aptSources() {
    # 在执行前确定有操作权限
    rm -f /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse' > /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse' >> /etc/apt/sources.list
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse' >> /etc/apt/sources.list
    echo "===================apt已修改为国内源==================="
}
# 修改pip源
pipSources() {
    # 在执行前确定有操作权限
    mkdir -p /root/.pip
    echo '[global]' > /root/.pip/pip.conf
    echo 'index-url = https://mirrors.aliyun.com/pypi/simple' >> /root/.pip/pip.conf
    echo '[install]' >> /root/.pip/pip.conf
    echo 'trusted-host = mirrors.aliyun.com' >> /root/.pip/pip.conf
    echo "===================pip已修改为国内源==================="
}
# 修改npm源
npmSources() {
    # 在执行前确定有操作权限
    npm config set registry https://registry.npmmirror.com -g
    echo "===================npm已修改为国内源==================="
}
# 修改yarn源
yarnSources() {
    # 在执行前确定有操作权限
    yarn config set registry https://registry.npm.taobao.org --global
    yarn config set sass_binary_site "https://cdn.npm.taobao.org/dist/node-sass/" --global
    # yarn config set phantomjs_cdnurl "http://cnpmjs.org/downloads" --global
    # yarn config set electron_mirror "https://npm.taobao.org/mirrors/electron/" --global
    # yarn config set sqlite3_binary_host_mirror "https://foxgis.oss-cn-shanghai.aliyuncs.com/" --global
    # yarn config set profiler_binary_host_mirror "https://npm.taobao.org/mirrors/node-inspector/" --global
    # yarn config set chromedriver_cdnurl "https://cdn.npm.taobao.org/dist/chromedriver" --global
    echo "===================yarn已修改为国内源==================="
}
if [ "$(echo $* |grep -o apt)" == "apt" ];then
    aptSources
fi
if [ "$(echo $* |grep -o pip)" == "pip" ];then
    pipSources
fi
if [ "$(echo $* |grep -o npm)" == "npm" ];then
    npmSources
fi
if [ "$(echo $* |grep -o yarn)" == "yarn" ];then
    yarnSources
fi
if [ "$(echo $* |grep -o all)" == "all" ];then
    aptSources
    pipSources
    npmSources
    yarnSources
fi
