#!/bin/bash
set -e
# 修改apt源
echo "===================修改apt源==================="
rm -f /etc/apt/sources.list
echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse' > /etc/apt/sources.list
echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse' >> /etc/apt/sources.list
# 修改pip源
echo "===================修改pip源==================="
mkdir -p /root/.pip
echo '[global]' > /root/.pip/pip.conf
echo 'index-url = https://mirrors.aliyun.com/pypi/simple' >> /root/.pip/pip.conf
echo '[install]' >> /root/.pip/pip.conf
echo 'trusted-host = mirrors.aliyun.com' >> /root/.pip/pip.conf
# 修改用户pip源
echo "===================修改用户pip源==================="
cp -af /root/.pip /home/frappe/
echo "===================修改npm源==================="
npm config set registry https://registry.npm.taobao.org
echo "===================修改yarn源==================="
yarn config set registry https://registry.npm.taobao.org
