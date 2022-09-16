FROM cym1102/nginxwebui:latest AS nginxwebui

FROM jeessy/ddns-go:latest AS ddns-go

FROM ubuntu:22.04
ENV LANG=zh_CN.UTF-8 \
    TZ=Asia/Shanghai
RUN apt update &&\
    DEBIAN_FRONTEND=noninteractive apt upgrade -y &&\
    DEBIAN_FRONTEND=noninteractive apt install -y \
        supervisor \
        openjdk-11-jdk \
        nginx \
        net-tools \
        curl \
        wget \
        tzdata &&\
    ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime &&\
    echo "${TZ}" > /etc/timezone &&\
    apt clean &&\
    apt autoremove -y &&\
    rm -rf /var/lib/apt/lists/*
COPY --from=nginxwebui /home/nginxWebUI.jar /entrypoint/nginxWebUI.jar
COPY --from=ddns-go /app/ddns-go /entrypoint/ddns-go
COPY ./*.conf /etc/supervisor/conf.d/
COPY ./entrypoint.sh /entrypoint/entrypoint.sh
RUN ["chmod", "+x", "/entrypoint/entrypoint.sh"]
VOLUME ["/app"]
EXPOSE 80 443 8080 9000 9876
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/entrypoint/entrypoint.sh"]
