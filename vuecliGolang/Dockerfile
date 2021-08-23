# erpnext
FROM node:latest
LABEL author=lvxj11

# 拷贝基础软件安装脚本
COPY ./installdata/installapp.sh /installdata/installapp.sh

# 运行基础软件安装脚本
RUN chmod -R 777 /installdata/* && /installdata/installapp.sh noMirror

# 设定工作目录
# USER username
WORKDIR /myProject

VOLUME /myProject

STOPSIGNAL SIGTERM

# ENTRYPOINT ["bash"]
# CMD ["/installdata/start.sh"]
CMD /bin/bash -c "while true;do echo hello docker;sleep 3600;done"
