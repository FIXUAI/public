#!/bin/bash
#wget -N "https://raw.githubusercontent.com/jin-gubang/public/main/docker_restart_tm.sh" --no-check-certificate && chmod +x docker_restart_tm.sh && bash docker_restart_tm.sh
# 颜色
RED="\e[31m"
GREEN="\e[32m"
echo "--- docker_restart_tm定时任务进行重启 ---" # 打印标题
# 显示处理前的 crontab 列表
echo -e "${GREEN}1.显示处理前的 crontab 列表"
crontab -l

# 提示开始处理 crontab
echo -e "${GREEN}2.开始处理 crontab"
# 将当前的 crontab 配置导出到临时文件 conf 中
crontab -l > conf
# 向 conf 文件追加一条新的定时任务：每月1日0点0分重启 docker 容器 tm，并记录日志
echo "0 0 1 * * docker restart tm >> /root/docker_restart_log_tm.txt" >> conf
# 从 conf 文件导入新的 crontab 配置
crontab conf
# 删除临时文件 conf
rm -f conf
# 提示结束处理 crontab
echo -e "${GREEN}3.处理完成 crontab"
# 显示处理后的 crontab 列表
echo -e "${GREEN}4.显示处理后的 crontab 列表"
crontab -l
echo -e "\n-----------------------------------" # 打印分隔线
