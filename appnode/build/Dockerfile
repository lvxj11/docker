# 使用官方centos7镜像
FROM centos:7
LABEL author=appnode

#安装appnode面板
RUN yum update -y \
    && yum install -y curl \
    && INSTALL_AGENT=1 INSTALL_APPS=sitemgr INIT_SWAPFILE=1 INSTALL_PKGS='nginx-stable,php56,php73' bash -c "$(curl -sS http://dl.appnode.com/install.sh)"

#初始化并拉取erpnext应用
ENV MARIADB_HOST=mariadb
ENV REDIS_HOST=redis
ENV MARIADB_ROOT_PASSWORD=Pass0129
ENV ADMIN_PASSWORD=admin

COPY ./frappe-config /frappe-config

RUN bash -c "echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf" \
    && cd /home/frappe \
    && bench init --frappe-branch version-12 --skip-redis-config-generation frappe-bench \
    && cd /home/frappe/frappe-bench \
    && bench get-app --branch version-12 erpnext https://github.com/frappe/erpnext \
    && sudo chmod -R 777 /frappe-config/* \
    && sudo mv /home/frappe/frappe-bench/sites/common_site_config.json /home/frappe/frappe-bench/sites/common_site_config.json.bak \
    && sudo cp -a /frappe-config/common_site_config.json /home/frappe/frappe-bench/sites/common_site_config.json \
    && sudo rm -f /etc/nginx/sites-enabled/default \
    && sudo cp -a /frappe-config/frappe-nginx.conf /etc/nginx/sites-available/erpnext \
    && sudo cp -a /frappe-config/frappe-nginx.conf /home/frappe/frappe-bench/config/nginx.conf \
    && sudo ln -s /home/frappe/frappe-bench/config/nginx.conf /etc/nginx/sites-enabled/nginx.conf \
    && sudo ln -s /frappe-config/add-site.sh /home/frappe/.local/bin/add-site \
    && sudo ln -s /frappe-config/multi-site.sh /home/frappe/.local/bin/multi-site \
    && sudo ln -s /frappe-config/init-start.sh /init-start.sh

EXPOSE 80 443

VOLUME /opt/appnode
VOLUME /data
VOLUME /etc/nginx
VOLUME /etc/opt/appnode

STOPSIGNAL SIGTERM

ENTRYPOINT /init-start.sh
#CMD ["/init-start.sh"]
