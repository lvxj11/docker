# Frappe Bench Dockerfile
FROM ubuntu:18.04
LABEL author=lvxj11

# 前期准备，设置环境语言安装必要软件，新建用户并添加sudo权限，切换到用户和目录运行安装脚本。
RUN export LC_ALL=C.UTF-8 \
  && export LANG=C.UTF-8 \
  && apt update \
  && apt upgrade -y \
  && apt install -y python3-minimum build-essential python3-setuptools wget \
  && adduser frappe \
  && usermod -aG sudo frappe \
  && su - frappe \
  && cd /home/frappe \
  && wget https://raw.githubusercontent.com/frappe/bench/develop/install.py \
  && set 's/pass_set = True/pass_set = False/' /home/frappe/install.py \
  && python3 install.py --production --mysql-root-password Pass0129 --admin-password admin

# 设置运行用户与目录
USER frappe
WORKDIR /home/frappe

# 开放端口
EXPOSE 80 443 8000

# 卷目录
VOLUME /home/frappe/frappe-bench/sites
