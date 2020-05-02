#！/bin/bash
docker exec -it erpnext_frappe_1 bash -c "/frappe-config/add-site.sh $1"