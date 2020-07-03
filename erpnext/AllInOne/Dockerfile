# Frappe Bench Dockerfile
FROM ubuntu:18.04
LABEL author=lvxj11

# 前期准备，设置环境语言，新建用户并添加到root组，并设置运行目录。
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && export LC_ALL=C.UTF-8 \
  && export LANG=C.UTF-8 \
  && groupadd -g 1000 frappe \
  && useradd --no-log-init -r -m -u 1000 -g 1000 -G  sudo frappe \
  && echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && apt install -y python3-minimum build-essential python3-setuptools wget
USER frappe
WORKDIR /home/frappe

# 以新用户运行安装脚本。
RUN cd /home/frappe \
  && wget https://raw.githubusercontent.com/frappe/bench/develop/install.py \
  && set 's/pass_set = True/pass_set = False/' /home/frappe/install.py \
  && python3 install.py --production --mysql-root-password Pass0129 --admin-password admin

EXPOSE 80 443 8000

VOLUME /home/frappe/frappe-bench/sites
