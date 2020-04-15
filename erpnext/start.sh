#！/bin/bash
#启动容器服务
docker-compose up -d
#建立 site1.local 站点，可根据需要修改。
docker exec -it erpnext_frappe_1 bash -c "cd /home/frappe/frappe-bench && /frappe-config/add-site.sh site1.local"
