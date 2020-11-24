# 安装bench，并初始化
FROM ubuntu:18.04
LABEL author=lvxj11

# 拷贝bench源码
COPY ./bench-5.2.1 /tmp/.bench
COPY ./frappe-12.12.0 /home/frappe/frappe-bench/apps/frappe
COPY ./erpnext-12.14.0 /home/frappe/frappe-bench/apps/erpnext

# 开始安装
RUN apt update && apt upgrade -y \
    && apt install -y python3-minimal build-essential python3-setuptools dialog locales aptitude apt-utils sudo wget curl git \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && groupadd -g 1000 frappe \
    && useradd --no-log-init -r -m -u 1000 -g 1000 -G  sudo frappe \
    && echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && echo -e "LC_ALL=en_US.UTF-8\nLC_CTYPE=en_US.UTF-8\nLANG=en_US.UTF-8" >> /etc/environment \
    && cd /tmp/.bench \
    && export LANG=C.UTF-8 \
    && export LC_ALL=C.UTF-8 \
    && python3 install.py --production --container \
        --mysql-root-password Pass0129 \
        --admin-password admin \
        --version 12 \
        --user frappe \
    && apt autoremove && apt clean


EXPOSE 8000 9000 6787

VOLUME /home/frappe/frappe-Bench

STOPSIGNAL SIGTERM

ENTRYPOINT /init-start.sh
#CMD ["/init-start.sh"]
