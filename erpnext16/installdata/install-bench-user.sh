#!/bin/bash
GIT_REPO="https://github.com/frappe/bench.git"
GIT_BRANCH="v5.x"
# Install Python via pyenv
# export PYTHON_VERSION_V14=3.10.13
export PYTHON_VERSION=3.14.2
export PYENV_ROOT=/home/frappe/.pyenv
export PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

# From https://github.com/pyenv/pyenv#basic-github-checkout
git clone --depth 1 https://github.com/pyenv/pyenv.git .pyenv
# pyenv install $PYTHON_VERSION_V14
pyenv install $PYTHON_VERSION
# PYENV_VERSION=$PYTHON_VERSION_V14 pip install --no-cache-dir virtualenv
PYENV_VERSION=$PYTHON_VERSION pip install --no-cache-dir virtualenv
pyenv global $PYTHON_VERSION # $PYTHON_VERSION_v14
# sed -Ei -e '/^([^#]|$)/ {a export PYENV_ROOT="/home/frappe/.pyenv" a export PATH="$PYENV_ROOT/bin:$PATH" a ' -e ':a' -e '$!{n;ba};}' ~/.profile
if ! grep -q "PYENV_ROOT" ~/.profile; then
    echo 'export PYENV_ROOT="/home/frappe/.pyenv"' >> ~/.profile
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
fi
echo 'eval "$(pyenv init --path)"' >>~/.profile
echo 'eval "$(pyenv init -)"' >>~/.bashrc

# Clone and install bench in the local user home directory
# For development, bench source is located in ~/.bench
export PATH=/home/frappe/.local/bin:$PATH
# Skip editable-bench warning
# https://github.com/frappe/bench/commit/20560c97c4246b2480d7358c722bc9ad13606138
git clone ${GIT_REPO} --depth 1 -b ${GIT_BRANCH} .bench
pip install --no-cache-dir --user -e .bench
echo "export PATH=/home/frappe/.local/bin:\$PATH" >>/home/frappe/.bashrc
echo "export BENCH_DEVELOPER=1" >>/home/frappe/.bashrc

# Install Node via nvm
# export NODE_VERSION_14=16.20.2
export NODE_VERSION=24.12.0
export NVM_DIR=/home/frappe/.nvm
export PATH=${NVM_DIR}/versions/node/v${NODE_VERSION}/bin/:${PATH}

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
. ${NVM_DIR}/nvm.sh
# nvm install ${NODE_VERSION_14}
# nvm use v${NODE_VERSION_14}
# npm install -g yarn
nvm install ${NODE_VERSION}
nvm use v${NODE_VERSION}
npm install -g yarn
nvm alias default v${NODE_VERSION}
rm -rf ${NVM_DIR}/.cache
echo 'export NVM_DIR="/home/frappe/.nvm"' >>~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.bashrc