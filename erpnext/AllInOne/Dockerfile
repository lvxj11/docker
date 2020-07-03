# Frappe Bench Dockerfile
FROM ubuntu:18.04
LABEL author=lvxj11

# 前期准备，设置环境语言安装必要软件，新建用户并添加sudo权限。
RUN apt update \
  && apt upgrade -y \
  && apt install -y locales cron curl wget vim sudo iputils-ping watch tree nano software-properties-common bash-completion python3-minimal build-essential python3-setuptools \
  && export LANG=C.UTF-8 \
  && export LC_ALL=C.UTF-8 \
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && groupadd -g 1000 frappe \
  && useradd --no-log-init -r -m -u 1000 -g 1000 -G  sudo frappe \
  && echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 设置运行用户与目录
USER frappe
WORKDIR /home/frappe

# 下载脚本，修改脚本，运行安装脚本。
RUN cd /home/frappe \
  && wget https://raw.githubusercontent.com/frappe/bench/develop/install.py \
  && sudo sed -i -e 's/pass_set = True/pass_set = False/' /home/frappe/install.py \
  && sudo python3 install.py --production --mysql-root-password Pass0129 --admin-password admin

# 开放端口
EXPOSE 80 443 8000

# 卷目录
VOLUME /home/frappe/frappe-bench/sites
