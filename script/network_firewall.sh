#!/bin/bash
OPS_DIR="/home/lu/ops_platform"
CONF_DIR="${OPS_DIR}/config"
FIREWALL_CONF="${CONF_DIR}/firewall.conf"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 创建配置文件（不存在则初始化）
if [ ! -f ${FIREWALL_CONF} ]; then
    mkdir -p ${CONF_DIR} &>/dev/null
    echo "ALLOW_PORTS=80,443,5000,3306" > ${FIREWALL_CONF}
    echo "DENY_IPS=192.168.1.10,10.0.0.5" >> ${FIREWALL_CONF}
    echo -e "${YELLOW}已初始化防火墙配置文件：${FIREWALL_CONF}${NC}"
fi

# 加载配置
source ${FIREWALL_CONF}

# 菜单界面
clear
echo -e "${GREEN}==================== 网络与防火墙管理 ====================${NC}"
echo "1. 启动/启用UFW防火墙"
echo "2. 开放指定端口（从firewall.conf读取）"
echo "3. 屏蔽指定IP（从firewall.conf读取）"
echo "4. 查看网络连接与端口占用"
echo "5. 返回主菜单"
echo -e "${GREEN}=========================================================${NC}"
read -p "请输入操作序号（1-5）：" opt

case $opt in
    1)
        # 启动并启用UFW
        sudo ufw enable &>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}UFW防火墙已启动并设置开机自启${NC}"
            sudo ufw status
        else
            echo -e "${RED}UFW防火墙启动失败${NC}"
        fi
        ;;
    2)
        # 开放配置中的端口
        echo -e "${YELLOW}正在开放端口：${ALLOW_PORTS}${NC}"
        for port in $(echo ${ALLOW_PORTS} | tr ',' ' '); do
            sudo ufw allow ${port}/tcp &>/dev/null
            echo -e "${GREEN}已开放TCP端口${port}${NC}"
        done
        sudo ufw reload &>/dev/null
        ;;
    3)
        # 屏蔽配置中的IP
        echo -e "${YELLOW}正在屏蔽IP：${DENY_IPS}${NC}"
        for ip in $(echo ${DENY_IPS} | tr ',' ' '); do
            sudo ufw deny from ${ip} &>/dev/null
            echo -e "${GREEN}已屏蔽IP${ip}${NC}"
        done
        sudo ufw reload &>/dev/null
        ;;
    4)
        # 查看网络连接和端口占用
        echo -e "${YELLOW}\n===== 端口占用情况（TCP/UDP）=====${NC}"
        sudo ss -tulpn | head -20
        echo -e "${YELLOW}\n===== 活跃网络连接 =====${NC}"
        netstat -an | grep -E "ESTABLISHED|LISTEN" | head -15
        ;;
    5)
        # 返回主菜单
        clear
        exit 0
        ;;
    *)
        echo -e "${RED}输入无效！请选择1-5${NC}"
        sleep 1
        bash $0
        ;;
esac

