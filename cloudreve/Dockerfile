# cloudreve
FROM ubuntu:22.04
LABEL author=lvxj11

# 设定参数
ENV LANG=zh_CN.UTF-8 \
    TZ=Asia/Shanghai

# 运行基础软件安装脚本
RUN RUN apt update &&\
    DEBIAN_FRONTEND=noninteractive apt upgrade -y &&\
    DEBIAN_FRONTEND=noninteractive apt install -y tzdata &&\
    ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime &&\
    echo "${TZ}" > /etc/timezone &&\
    apt clean &&\
    apt autoremove -y &&\
    rm -rf /var/lib/apt/lists/*

# 设定工作目录
WORKDIR /cloudreve

EXPOSE 5212

# 必须挂载cloudreve目录，应用程序及授权文件自行放置到该目录并添加运行权限。
VOLUME ["/cloudreve"]

STOPSIGNAL SIGTERM

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["./cloudreve"]
