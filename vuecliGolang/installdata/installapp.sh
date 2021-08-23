#!/bin/bash
set -e
cd ~
# 更新系统
echo "===================更新系统==================="
apt update
apt upgrade -y
# 更新npm
echo "===================更新npm==================="
npm install -g npm
# 安装vuecil
echo "===================安装vuecil==================="
npm install -g @vue/cli
# 测试安装
echo "===================测试安装是否成功，如显示版本号为成功，否则安装失败。==================="
vue --version
# 安装golang
echo "===================安装golang==================="
wget -O go.tar.gz https://golang.google.cn/dl/go1.17.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
export PATH=$PATH:/usr/local/go/bin
# 测试安装
echo "===================测试安装是否成功，如显示版本号为成功，否则安装失败。==================="
go version
# 建立工作目录
echo "===================建立工作目录==================="
mkdir /myProject
# 清理垃圾,ERPNext安装完毕
echo "===================清理垃圾,ERPNext安装完毕==================="
apt clean
apt autoremove
rm -rf /var/lib/apt/lists/*
npm cache clean --force
yarn cache clean
exit 0
