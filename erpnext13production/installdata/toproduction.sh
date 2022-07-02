#!/bin/bash
# v0.1 2022.07.1
set -e
sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt upgrade -y
cd ~/frappe-bench
sudo bench setup production frappe --yes
bench doctor
bench version
