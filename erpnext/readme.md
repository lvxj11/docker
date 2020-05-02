# 开始使用
## 启动容器服务
`docker-compose up -d`
## 建立 site1.local 站点，可根据需要修改。
`docker exec -it erpnext_frappe_1 bash -c "cd /home/frappe/frappe-bench && /frappe-config/add-site.sh site1.local"`

# 添加站点
`docker exec -it erpnext_frappe_1 bash -c "add-site $1"`

# 恢复备份
## 使用bench恢复
`bench --force --site site1.local restore ~/frappe-bench/sites/site1.local/private/backups/20200423_120003-site1_local-database.sql.gz`
## 直接恢复数据库
`mysql -u root -pPass0129 -h mariadb _1bd3e0294da19198 <  ~/frappe-bench/sites/site1.local/private/backups/20200423_120003-site1_local-database.sql`
