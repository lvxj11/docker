#!/bin/sh
pkill mysqld
sleep 3
/usr/bin/mysqld_safe --pid-file=/var/run/mysqld/mysqld.pid &
