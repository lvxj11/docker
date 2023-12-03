# erpnext
FROM python:3.9-slim
LABEL author=lvxj11

# 设定参数
ENV URL ""
ENV INCLUDE ""

# 拷贝基础软件安装脚本
COPY ./SSRSpeedN /SSRSpeedN
COPY ./start.sh /start.sh

WORKDIR /SSRSpeedN

# 运行基础软件安装脚本。
RUN /bin/bash -c "chmod +x /start.sh \
    && apt update && DEBIAN_FRONTEND=noninteractive apt upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt install -y shadowsocks-libev simple-obfs trojan \
    && cd /SSRSpeedN \
    && pip install --upgrade pip \
    && pip install six Pillow==9.5.0 \
    && pip install -r requirements.txt"

VOLUME /SSRSpeedN/results

STOPSIGNAL SIGTERM

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/start.sh"]
