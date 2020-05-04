# 开始使用
## 建立并启动服务
1.下载“docker-compose.yml”和“frappe-mariadb.cnf”两个文件  
2.在两个文件的同目录执行`docker-compose up -d`  
3.建立 site1.local 站点，可根据需要修改站点名称。运行前请自行确认容器名称并修改。  
`docker exec -it erpnext_frappe_1 bash -c "add-site site1.local"`  
4.用浏览器访问“http://服务器地址或域名:端口号”，初始管理员账号“administrator”密码“admin”。  
端口号请查看或修改“docker-compose.yml”  

# 恢复备份
## 使用bench恢复,请自行修改路径及文件名。
`bench --force --site 站点名称 restore 数据库备份文件路径及名称`
## 直接恢复数据库,请自行修改路径及文件名。
`mysql -u 数据库用户名 -p密码 -h 数据库服务器地址 数据库名称 <  备份文件路径及名称`

# 启用多站点
## 启用DNS方式多站点，同端口自动识别域名连接正确站点。
`docker exec -it erpnext_frappe_1 bash -c "multi-site"`  
默认配置文件已开启DNS方式多站点，本次指令原理上是清空“currentsite.txt”文件取消默认站点的设置并重启容器，使多站点配置生效。  
