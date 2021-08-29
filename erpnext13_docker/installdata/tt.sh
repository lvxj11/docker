#!/bin/bash
if [ "$(echo $* |grep -o fromGitee)" == "fromGitee" ];then
    echo "有"
else
    echo "无"
fi
