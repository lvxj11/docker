FROM debian:bookworm-slim AS bench

LABEL author=frappé

ARG GIT_REPO=https://github.com/frappe/bench.git
ARG GIT_BRANCH=v5.x

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    # For frappe framework
    git \
    mariadb-client \
    postgresql-client \
    gettext-base \
    wget \
    # for PDF
    libssl-dev \
    fonts-cantarell \
    xfonts-75dpi \
    xfonts-base \
    # weasyprint dependencies
    libpango-1.0-0 \
    libharfbuzz0b \
    libpangoft2-1.0-0 \
    libpangocairo-1.0-0 \
    # to work inside the container
    locales \
    build-essential \
    cron \
    curl \
    vim \
    sudo \
    iputils-ping \
    watch \
    tree \
    nano \
    less \
    software-properties-common \
    bash-completion \
    # For psycopg2
    libpq-dev \
    # Other
    libffi-dev \
    liblcms2-dev \
    libldap2-dev \
    libmariadb-dev \
    libsasl2-dev \
    libtiff5-dev \
    libwebp-dev \
    pkg-config \
    redis-tools \
    rlwrap \
    tk8.6-dev \
    ssh-client \
    # VSCode container requirements
    net-tools \
    # For pyenv build dependencies
    # https://github.com/frappe/frappe_docker/issues/840#issuecomment-1185206895
    make \
    # For pandas
    libbz2-dev \
    # For bench execute
    libsqlite3-dev \
    # For other dependencies
    zlib1g-dev \
    libreadline-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    liblzma-dev \
    file \
    # For MIME type detection
    media-types \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales

# Detect arch and install wkhtmltopdf
ARG WKHTMLTOPDF_VERSION=0.12.6.1-3
ARG WKHTMLTOPDF_DISTRO=bookworm
RUN if [ "$(uname -m)" = "aarch64" ]; then export ARCH=arm64; fi \
    && if [ "$(uname -m)" = "x86_64" ]; then export ARCH=amd64; fi \
    && downloaded_file=wkhtmltox_${WKHTMLTOPDF_VERSION}.${WKHTMLTOPDF_DISTRO}_${ARCH}.deb \
    && wget -q https://github.com/wkhtmltopdf/packaging/releases/download/$WKHTMLTOPDF_VERSION/$downloaded_file \
    && dpkg -i $downloaded_file \
    && rm $downloaded_file

# Create new user with home directory, improve docker compatibility with UID/GID 1000,
# add user to sudo group, allow passwordless sudo, switch to that user
# and change directory to user home directory
RUN groupadd -g 1000 frappe \
    && useradd --no-log-init -r -m -u 1000 -g 1000 -G sudo frappe \
    && echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER frappe
WORKDIR /home/frappe

# Install Python via pyenv
# ENV PYTHON_VERSION_V14=3.10.13
ENV PYTHON_VERSION=3.14.2
ENV PYENV_ROOT=/home/frappe/.pyenv
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

# From https://github.com/pyenv/pyenv#basic-github-checkout
RUN git clone --depth 1 https://github.com/pyenv/pyenv.git .pyenv \
    # && pyenv install $PYTHON_VERSION_V14 \
    && pyenv install $PYTHON_VERSION \
    # && PYENV_VERSION=$PYTHON_VERSION_V14 pip install --no-cache-dir virtualenv \
    && PYENV_VERSION=$PYTHON_VERSION pip install --no-cache-dir virtualenv \
    && pyenv global $PYTHON_VERSION $PYTHON_VERSION_v14 \
    && sed -Ei -e '/^([^#]|$)/ {a export PYENV_ROOT="/home/frappe/.pyenv" a export PATH="$PYENV_ROOT/bin:$PATH" a ' -e ':a' -e '$!{n;ba};}' ~/.profile \
    && echo 'eval "$(pyenv init --path)"' >>~/.profile \
    && echo 'eval "$(pyenv init -)"' >>~/.bashrc

# Clone and install bench in the local user home directory
# For development, bench source is located in ~/.bench
ENV PATH=/home/frappe/.local/bin:$PATH
# Skip editable-bench warning
# https://github.com/frappe/bench/commit/20560c97c4246b2480d7358c722bc9ad13606138
RUN git clone ${GIT_REPO} --depth 1 -b ${GIT_BRANCH} .bench \
    && pip install --no-cache-dir --user -e .bench \
    && echo "export PATH=/home/frappe/.local/bin:\$PATH" >>/home/frappe/.bashrc \
    && echo "export BENCH_DEVELOPER=1" >>/home/frappe/.bashrc

# Install Node via nvm
# ENV NODE_VERSION_14=16.20.2
ENV NODE_VERSION=24.12.0
ENV NVM_DIR=/home/frappe/.nvm
ENV PATH=${NVM_DIR}/versions/node/v${NODE_VERSION}/bin/:${PATH}

RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash \
    && . ${NVM_DIR}/nvm.sh \
    # && nvm install ${NODE_VERSION_14} \
    # && nvm use v${NODE_VERSION_14} \
    && npm install -g yarn \
    && nvm install ${NODE_VERSION} \
    && nvm use v${NODE_VERSION} \
    && npm install -g yarn \
    && nvm alias default v${NODE_VERSION} \
    && rm -rf ${NVM_DIR}/.cache \
    && echo 'export NVM_DIR="/home/frappe/.nvm"' >>~/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.bashrc

FROM bench AS erpnext

USER root
WORKDIR /root

# 安装支持软件
ARG MARIADB_CONFIG_FILE=/etc/mysql/mariadb.conf.d/99-erpnext.cnf
ARG SUPERVISOR_CONFIG_DIR=/etc/supervisor/conf.d
RUN apt-get update \
    && curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=11.8 \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        redis-server \
        mariadb-server \
        mariadb-client \
        nginx \
        supervisor \
    && sudo rm -rf /var/lib/apt/lists/* \
    && echo "[mysqld]" >> ${MARIADB_CONFIG_FILE} \
    && echo "character-set-client-handshake=FALSE" >> ${MARIADB_CONFIG_FILE} \
    && echo "character-set-server=utf8mb4" >> ${MARIADB_CONFIG_FILE} \
    && echo "collation-server=utf8mb4_unicode_ci" >> ${MARIADB_CONFIG_FILE} \
    && echo "bind-address=0.0.0.0" >> ${MARIADB_CONFIG_FILE} \
    && echo "innodb_file_per_table=1" >> ${MARIADB_CONFIG_FILE} \
    && echo "innodb_file_format=Barracuda" >> ${MARIADB_CONFIG_FILE} \
    && echo "innodb_large_prefix=ON" >> ${MARIADB_CONFIG_FILE} \
    && echo "" >> ${MARIADB_CONFIG_FILE} \
    && echo "[mysql]" >> ${MARIADB_CONFIG_FILE} \
    && echo "default-character-set=utf8mb4" >> ${MARIADB_CONFIG_FILE} \
    && echo "[program:mariadb]" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "command=/usr/sbin/mariadbd --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib/mysql/plugin --user=mysql --skip-log-error" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "priority=1" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "autostart=true" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "autorestart=true" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "numprocs=1" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "startretries=10" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "stopwaitsecs=10" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "redirect_stderr=true" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "stdout_logfile_maxbytes=1024MB" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "stdout_logfile_backups=10" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "stdout_logfile=/var/run/log/supervisor_mysql.log" >> ${SUPERVISOR_CONFIG_DIR}/mariadb.conf \
    && echo "[program:nginx]" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "command=/usr/sbin/nginx -g 'daemon off;'" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "autorestart=true" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "autostart=true" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "stderr_logfile=/var/run/log/supervisor_nginx_error.log" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "stdout_logfile=/var/run/log/supervisor_nginx_stdout.log" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "environment=ASPNETCORE_ENVIRONMENT=Production" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "user=root" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "stopsignal=INT" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "startsecs=10" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "startretries=5" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf \
    && echo "stopasgroup=true" >> ${SUPERVISOR_CONFIG_DIR}/nginx.conf

USER frappe
WORKDIR /home/frappe

ENV PYTHONPATH=/home/frappe/.bench:/home/frappe/.pyenv/versions/3.14.2/lib/python3.14/site-packages:/home/frappe/frappe-bench/env/lib/python3.14/site-packages
ENV PATH=/home/frappe/.local/bin:/home/frappe/.pyenv/shims:/home/frappe/.pyenv/bin:${PATH}
RUN sudo /usr/bin/supervisord -c /etc/supervisor/supervisord.conf \
    && sleep 10 \
    && bench init --frappe-branch version-16 --ignore-exist frappe-bench --frappe-path \
    && cd /home/frappe/frappe-bench \
    && bench get-app --branch version-16 "https://github.com/frappe/erpnext" \
    && bench new-site --mariadb-root-username "root" --mariadb-root-password Pass1234 --db-password Pass1234 --admin-password admin site1.local \
    && bench config http_timeout 6000 \
    && bench config serve_default_site on \
    && bench use site1.local \
    && bench start > bench-start.log 2>&1 & \
    && sleep 10 \
    && bench --site site1.local install-app erpnext \
    # 容器中运行fail2ban需要特权模式，这里注释掉代码开启生产模式时将不再安装fail2ban。防火墙需要宿主机自行维护。 \
    && n=$(sed -n "/^[[:space:]]*if not which.*fail2ban-client/=" "/home/frappe/.bench/bench/config/production_setup.py") \
    && sudo sed -i "${n} s/^/#&/" "/home/frappe/.bench/bench/config/production_setup.py" \
    && let n++ \
    && sudo sed -i "${n} s/^/#&/" "/home/frappe/.bench/bench/config/production_setup.py" \
    && sudo bench setup production frappe --yes \
    && pip cache purge \
    && npm cache clean --force \
    && yarn cache clean \
    && bench clear-cache \
    && bench clear-website-cache \
    && sudo /usr/bin/supervisorctl status \
    && cd /home/frappe/frappe-bench \
    && bench version

EXPOSE 3306 80

VOLUME /home/frappe/frappe-bench/sites
VOLUME /var/lib/mysql

STOPSIGNAL SIGTERM

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["sudo /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf"]
