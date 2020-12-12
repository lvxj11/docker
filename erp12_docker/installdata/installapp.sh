#!/bin/sh
# DEBIAN_FRONTEND=noninteractive
apt update && apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y python3-minimal build-essential python3-setuptools cron locales aptitude apt-utils sudo wget curl git tzdata
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo -e "LC_ALL=en_US.UTF-8\nLC_CTYPE=en_US.UTF-8\nLANG=en_US.UTF-8" >> /etc/environment
ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
groupadd -g 1000 frappe
useradd --no-log-init -r -m -u 1000 -g 1000 -G  sudo frappe
echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
chown -R frappe.frappe /home/frappe
cp -a ./bench-5.2.1 /tmp/.bench
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
cd /tmp/.bench
python3 install.py --production --container  --mysql-root-password Pass0129  --admin-password admin  --version 12  --user frappe
