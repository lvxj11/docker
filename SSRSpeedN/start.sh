#!/bin/bash

# 在main.py中查找input开头的行，在行首添加#号，不改变行内容
sed -i 's/^input.*/#&/' /SSRSpeedN/main.py

# 如果URL为空，则退出
if [ -z "${URL}" ]; then
    echo "没有设置URL，请设置URL或手动添加指令。"
else
    if [ -z "${INCLUDE}" ]; then
        python3 main.py -u ${URL}
    else
        python3 main.py -u ${URL} --include ${INCLUDE}
    fi
fi
