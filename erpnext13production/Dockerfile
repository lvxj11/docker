# erpnext
FROM lvxj11/erpnext:latest
LABEL author=lvxj11


# 设定工作用户及工作目录
USER frappe
WORKDIR /home/frappe/frappe-bench

# 开始安装
RUN /bin/bash -c 'set -ex; \
    sudo apt update; \
    f="/usr/local/lib/python3.8/dist-packages/bench/config/supervisor.py"; \
    n=$(sed -n "/service.*supervisor.*reload/=" ${f}); \
    if [ ${n} ]; then sudo sed -i "${n} s/reload/restart/g" ${f}; fi; \
    cd ~/frappe-bench; \
    f="/etc/supervisor/conf.d/frappe-bench.conf"; \
    while [ ! -e ${f} ]; do sudo bench setup production frappe --yes; done; \
    mkdir /home/frappe/frappe-bench/config/supervisor; \
    echo "[program:mariadb]" > /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "command=/usr/sbin/mysqld \
    --basedir=/usr \
    --datadir=/var/lib/mysql \
    --plugin-dir=/usr/lib/x86_64-linux-gnu/mariadb19/plugin \
    --user=mysql --skip-log-error \
    --pid-file=/run/mysqld/mysqld.pid \
    --socket=/var/run/mysqld/mysqld.sock" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "priority=1" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "autostart=true" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "autorestart=true" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "numprocs=1" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "startretries=10" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "exitcodes=0" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "stopsignal=KILL" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "stopwaitsecs=10" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "redirect_stderr=true" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "stdout_logfile_maxbytes=1024MB" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "stdout_logfile_backups=10" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    echo "stdout_logfile=/var/run/log/mysql.log" >> /home/frappe/frappe-bench/config/supervisor/mysql.conf; \
    sudo ln -s /home/frappe/frappe-bench/config/supervisor/mysql.conf /etc/supervisor/conf.d/mysql.conf; \
    echo "[program: nginx]" > /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    t="daemon off;"; \
    echo "command=/usr/sbin/nginx -g ${t}" >> /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    echo "autorestart=true" >> /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    echo "autostart=true" >> /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    echo "stderr_logfile=/var/run/log/nginx_error.log" >> /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    echo "stdout_logfile=/var/run/log/nginx_stdout.log" >> /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    echo "environment=ASPNETCORE_ENVIRONMENT=Production" >> /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    echo "user=root" >> /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    echo "stopsignal=INT" >> /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    echo "startsecs=10" >> /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    echo "startretries=5" >> /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    echo "stopasgroup=true" >> /home/frappe/frappe-bench/config/supervisor/nginx.conf; \
    sudo ln -s /home/frappe/frappe-bench/config/supervisor/nginx.conf /etc/supervisor/conf.d/nginx.conf'

# 开放端口
EXPOSE 80

# 设定存储卷
VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

# 设定信号
STOPSIGNAL SIGTERM

#设定入口指令
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["sudo supervisord -c /etc/supervisor/supervisord.conf"]
