# Frappe Bench Dockerfile
FROM ubuntu:18.04
LABEL author=lvxj11

# 以下为新增
ENV MARIADB_ROOT_PASSWORD=Pass0129
ENV ADMIN_PASSWORD=admin

COPY ./frappe-config /home/frappe/frappe-config

# 安装并配置frappe
RUN apt update && apt upgrade -y \
    && apt install -y python3-minimal build-essential python3-setuptools dialog locales aptitude apt-utils sudo wget curl git \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && export LANG=C.UTF-8 \
    && export LC_ALL=C.UTF-8 \
    && groupadd -g 1000 frappe \
    && useradd --no-log-init -r -m -u 1000 -g 1000 -G  sudo frappe \
    && echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && wget https://raw.githubusercontent.com/frappe/bench/develop/install.py \
    && python3 install.py --production --container --mysql-root-password Pass0129 --admin-password admin --version 12 \
    && bash -c "echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf" \
    && cd /home/frappe \
    && bash -c "sudo nohup mysqld_safe &" \
    && sudo service redis-server restart \
    && sleep 3 \
    && sudo mysqladmin -u root password Pass0129 \
    && sudo cp -a /home/frappe/frappe-config/frappe-mariadb.cnf /etc/mysql/conf.d/frappe.cnf \
    && bench init --frappe-branch version-12 frappe-bench \
    && cd /home/frappe/frappe-bench \
    && bench get-app --branch version-12 erpnext https://github.com/frappe/erpnext \
    && sudo chmod -R 777 /home/frappe/frappe-config/* \
    && echo "export PATH=/home/frappe/frappe-config:\$PATH" >> /home/frappe/.bashrc \
    && sudo mv /home/frappe/frappe-bench/sites/common_site_config.json /home/frappe/frappe-bench/sites/common_site_config.json.bak \
    && sudo cp -a /home/frappe/frappe-config/common_site_config.json /home/frappe/frappe-bench/sites/common_site_config.json \
    && sudo ln -s /home/frappe/frappe-config/init-start.sh /init-start.sh \
    && bench new-site --mariadb-root-password Pass0129 --admin-password admin site1.local

EXPOSE 8000-8005 9000-9005 6787

VOLUME /home/frappe/frappe-bench/sites

STOPSIGNAL SIGTERM

ENTRYPOINT /init-start.sh
