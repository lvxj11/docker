apt install -y python3-minimal build-essential python3-setuptools dialog locales aptitude apt-utils sudo wget curl git
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
groupadd -g 1000 frappe
useradd --no-log-init -r -m -u 1000 -g 1000 -G  sudo frappe
echo "frappe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo -e "LC_ALL=en_US.UTF-8\nLC_CTYPE=en_US.UTF-8\nLANG=en_US.UTF-8" >> /etc/environment
su frappe
cd
wget https://raw.githubusercontent.com/frappe/bench/develop/install.py
python3 install.py --production --container \
    --mysql-root-password Pass0129 \
    --admin-password admin \
    --version 12\
    --user frappe \
    --repo-url https://gitee.com/lvxj11/bench \
    --frappe-repo-url https://gitee.com/lvxj11/frappe \
    --erpnext-repo-url https://gitee.com/lvxj11/erpnext
