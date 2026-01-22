#!/bin/bash
GIT_REPO="https://github.com/frappe/bench.git"
GIT_BRANCH="v5.x"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
    --no-install-recommends \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    git \
    mariadb-client \
    postgresql-client \
    gettext-base \
    wget \
    libssl-dev \
    fonts-cantarell \
    xfonts-75dpi \
    xfonts-base \
    libpango-1.0-0 \
    libharfbuzz0b \
    libpangoft2-1.0-0 \
    libpangocairo-1.0-0 \
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
    libpq-dev \
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
    net-tools \
    make \
    libbz2-dev \
    libsqlite3-dev \
    zlib1g-dev \
    libreadline-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    liblzma-dev \
    file \
    media-types
rm -rf /var/lib/apt/lists/*
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
dpkg-reconfigure --frontend=noninteractive locales
# Detect arch and install wkhtmltopdf
WKHTMLTOPDF_VERSION=0.12.6.1-3
WKHTMLTOPDF_DISTRO=bookworm
if [ "$(uname -m)" = "aarch64" ]; then
    export ARCH=arm64
fi
if [ "$(uname -m)" = "x86_64" ]; then
    export ARCH=amd64
fi
downloaded_file=wkhtmltox_${WKHTMLTOPDF_VERSION}.${WKHTMLTOPDF_DISTRO}_${ARCH}.deb
wget -q https://github.com/wkhtmltopdf/packaging/releases/download/$WKHTMLTOPDF_VERSION/$downloaded_file
dpkg -i $downloaded_file
rm $downloaded_file
groupadd -g 1000 frappe
useradd --no-log-init -r -m -u 1000 -g 1000 -G sudo frappe
echo "root	ALL=(ALL:ALL) ALL" > /etc/sudoers
echo "%sudo	ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
