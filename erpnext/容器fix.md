## 修改内容
### 修改`存储路径/bench/playbooks/site.yml`文件，使其能在容器内安装。
1. `- { role: locale,tags: locale }`  
修改为  
`- { role: locale,tags: locale,when: not container }`。
2. `- { role: mariadb,tags: mariadb }`  
修改为  
`- { role: mariadb,tags: mariadb,when: not container }`。
3. `- { role: nginx,tags: nginx,when: production}`  
修改为  
`- { role: nginx,tags: nginx,when: production and not container }`。
### 修改`存储路径/bench/playbooks/roles/bench/tasks/setup_erpnext.yml`文件，使其能在容器内安装。
```
  - name: Create a new site
    command: "bench new-site {{ site }} --admin-password '{{ admin_password }}' --mariadb-root-password '{{ mysql_root_password }}'"
    args:
      chdir: "{{ bench_path }}"
    when: not site_folder.stat.exists

  - name: Install ERPNext to default site
    command: "bench --site {{ site }} install-app erpnext"
    args:
      chdir: "{{ bench_path }}"
    when: not without_erpnext
```  
修改为  
```
  - name: Create a new site
    command: "bench new-site {{ site }} --admin-password '{{ admin_password }}' --mariadb-root-password '{{ mysql_root_password }}'"
    args:
      chdir: "{{ bench_path }}"
    when: not site_folder.stat.exists and not container

  - name: Install ERPNext to default site
    command: "bench --site {{ site }} install-app erpnext"
    args:
      chdir: "{{ bench_path }}"
    when: not without_erpnext and not container
```  
