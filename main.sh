#!/bin/bash
OPS_DIR="/home/lu/ops_platform"
SCRIPT_DIR="${OPS_DIR}/script"
LOG_DIR="${OPS_DIR}/log"
BLOG_DIR="${OPS_DIR}/blog_app"
CONF_DIR="${OPS_DIR}/config"
mkdir -p ${SCRIPT_DIR} ${LOG_DIR} ${BLOG_DIR}/{templates,static/css} ${CONF_DIR} &>/dev/null

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查脚本是否存在
check_script() {
    if [ ! -f "${SCRIPT_DIR}/$1" ]; then
        echo -e "${RED}错误：缺失脚本 ${SCRIPT_DIR}/$1${NC}"
        exit 1
    fi
}

# 欢迎界面
clear
echo -e "${GREEN}===== Ubuntu 22.04 自动化运维平台 v3.0 =====${NC}"
echo -e "${YELLOW}功能：服务监控+用户管理+Docker+博客+防火墙+Git版本管理${NC}\n"

# 检查所有子脚本
check_script "service_monitor.sh"
check_script "user_mgr.sh"
check_script "docker_mgr.sh"
check_script "blog_mgr.sh"
check_script "network_firewall.sh"
check_script "git_sync.sh"

# 主菜单
select opt in "服务状态监控" "运维用户管理" "Docker容器管理" "Python博客运维" "网络与防火墙管理" "Git版本同步" "退出系统"; do
    case $opt in
        "服务状态监控")
            ${SCRIPT_DIR}/service_monitor.sh
            read -p "按回车键返回主菜单..."
            clear
            ;;
        "运维用户管理")
            ${SCRIPT_DIR}/user_mgr.sh
            read -p "按回车键返回主菜单..."
            clear
            ;;
        "Docker容器管理")
            ${SCRIPT_DIR}/docker_mgr.sh
            read -p "按回车键返回主菜单..."
            clear
            ;;
        "Python博客运维")
            ${SCRIPT_DIR}/blog_mgr.sh
            read -p "按回车键返回主菜单..."
            clear
            ;;
        "网络与防火墙管理")
            ${SCRIPT_DIR}/network_firewall.sh
            read -p "按回车键返回主菜单..."
            clear
            ;;
        "Git版本同步")
            ${SCRIPT_DIR}/git_sync.sh
            read -p "按回车键返回主菜单..."
            clear
            ;;
        "退出系统")
            echo -e "${GREEN}感谢使用运维平台，再见！${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}输入无效，请选择1-7的选项！${NC}"
            ;;
    esac
done
