#!/bin/bash
# v0.1 2022.07.1
set -e
sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt upgrade -y
DEBIAN_FRONTEND=noninteractive sudo apt install -y supervisor
sudo supervisor -c "/etc/supervisor/supervisord.conf"
cd ~/frappe-bench
sudo bench setup production frappe
bench doctor
bench version
