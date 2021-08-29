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
}
# 修改pip源
pipSources() {
    # 在执行前确定有操作权限
    mkdir -p /root/.pip
    echo '[global]' > /root/.pip/pip.conf
    echo 'index-url = https://mirrors.aliyun.com/pypi/simple' >> /root/.pip/pip.conf
    echo '[install]' >> /root/.pip/pip.conf
    echo 'trusted-host = mirrors.aliyun.com' >> /root/.pip/pip.conf
}
# 修改npm源
npmSources() {
    # 在执行前确定有操作权限
    npm config set registry https://registry.npm.taobao.org
}
# 修改yarn源
yarnSources() {
    # 在执行前确定有操作权限
    yarn config set registry https://registry.npm.taobao.org
    yarn config set sass_binary_site "https://npm.taobao.org/mirrors/node-sass/"
    yarn config set phantomjs_cdnurl "http://cnpmjs.org/downloads"
    yarn config set electron_mirror "https://npm.taobao.org/mirrors/electron/"
    yarn config set sqlite3_binary_host_mirror "https://foxgis.oss-cn-shanghai.aliyuncs.com/"
    yarn config set profiler_binary_host_mirror "https://npm.taobao.org/mirrors/node-inspector/"
    yarn config set chromedriver_cdnurl "https://cdn.npm.taobao.org/dist/chromedriver"
}
