#!/bin/bash
#https://github.com/jin-gubang/public
#wget -N "https://raw.githubusercontent.com/jin-gubang/public/main/show_time_info.sh" --no-check-certificate && chmod +x show_time_info.sh && bash show_time_info.sh
echo "--- 系统时间信息概览 ---" # 打印标题

# 1. 获取并显示系统当前时间 (本地时间和通用时间/UTC)
echo "1. 系统当前时间:"
timedatectl | grep -E 'Local time:|Universal time:' # 使用timedatectl命令，并过滤出本地时间和通用时间行

# 获取NTP服务器地址，以便后续使用
# timedatectl timesync-status会显示当前同步的NTP服务器信息
# grep 'Server:' 过滤出包含"Server:"的行
# awk '{print $2}' 提取该行的第二个字段（即服务器地址）
NTP_SERVER_ADDRESS=$(timedatectl timesync-status | grep -E 'Server:' | awk '{print $2}')

# 2. NTP 服务器当前时间 (间接获取，或通过sntp直接查询)
echo -e "\n2. NTP 服务器当前时间 (通常等同于系统的通用时间):"
timedatectl | grep 'Universal time:' # NTP服务器提供的时间会同步到系统的通用时间
# 检查系统中是否安装了sntp命令，sntp可以直接查询NTP服务器的时间
if command -v sntp &> /dev/null
then
    echo "   (通过 sntp 直接查询 $NTP_SERVER_ADDRESS):"
    sntp -s "$NTP_SERVER_ADDRESS" # 使用sntp直接查询NTP服务器的时间
    echo "   (通过 sntp 直接查询 ntp.ubuntu.com):"
    sntp -s ntp.ubuntu.com
else
    echo "   (提示: 如果想直接查询服务器时间，请安装 'sntp': sudo apt install sntp)"
fi

# 3. NTP 服务器地址
echo -e "\n3. NTP 服务器地址:"
# 检查NTP_SERVER_ADDRESS变量是否有值，以确定是否成功获取到服务器地址
if [ -n "$NTP_SERVER_ADDRESS" ]; then
    echo "   $NTP_SERVER_ADDRESS"
else
    echo "   未能确定NTP服务器地址，或NTP服务未激活。"
fi

# 4. 最近一次与NTP服务器进行校正的时间 (从日志中获取近似时间)
echo -e "\n4. 最近一次NTP同步事件 (来自 systemd-timesyncd 日志):"
# journalctl -u systemd-timesyncd 查询 systemd-timesyncd 服务的日志
# --since "240 hours ago" 限制查询最近240小时的日志
# grep -m 1 'Synchronized to NTP server' 查找第一条包含"Synchronized to NTP server"的日志（-m 1表示只匹配一条）
# head -n 1 再次确保只取第一行
# awk '{$1=$2=$3=$4=""; print $0}' 移除日志开头的时间戳和主机名，只保留同步信息
LAST_SYNC_TIME=$(journalctl -u systemd-timesyncd --since "240 hours ago" | grep -m 1 'Synchronized to NTP server' | head -n 1 | awk '{$1=$2=$3=$4=""; print $0}')
# 检查是否找到同步事件
if [ -n "$LAST_SYNC_TIME" ]; then
    echo "   $LAST_SYNC_TIME"
else
    echo "   在过去240小时的日志中未找到最近的同步事件，或NTP服务未激活。"
fi

echo -e "\n-----------------------------------" # 打印分隔线
