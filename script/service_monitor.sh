#!/bin/bash
OPS_DIR="/home/lu/ops_platform"
LOG_DIR="${OPS_DIR}/log"
LOG_FILE="${LOG_DIR}/service_monitor_$(date +%Y%m%d).log"
ALERT_EMAIL="ops@example.com"
BLOG_CONTAINER="python-blog"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 日志写入函数
log_write() {
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') $1" | tee -a ${LOG_FILE}
}

# 检测Nginx状态
check_nginx() {
    if ! systemctl is-active --quiet nginx; then
        log_write "${RED}Nginx服务异常，尝试重启...${NC}"
        sudo systemctl start nginx &>/dev/null
        if systemctl is-active --quiet nginx; then
            log_write "${GREEN}Nginx重启成功${NC}"
            echo "Nginx服务异常，已自动重启" | mail -s "Nginx告警" ${ALERT_EMAIL} 2>/dev/null
        else
            log_write "${RED}Nginx重启失败，请手动处理！${NC}"
            echo "Nginx重启失败，需手动干预" | mail -s "Nginx紧急告警" ${ALERT_EMAIL} 2>/dev/null
        fi
    else
        log_write "${GREEN}Nginx服务运行正常${NC}"
    fi
}

# 检测MySQL容器状态
check_mysql() {
    if ! command -v docker &>/dev/null; then
        log_write "${YELLOW}Docker未安装，跳过MySQL容器检测${NC}"
        return
    fi
    if ! docker ps --filter "name=mysql" --format "{{.Status}}" | grep -q "Up"; then
        log_write "${RED}MySQL容器异常，尝试重启...${NC}"
        docker start mysql &>/dev/null
        if docker ps --filter "name=mysql" --format "{{.Status}}" | grep -q "Up"; then
            log_write "${GREEN}MySQL容器重启成功${NC}"
        else
            log_write "${RED}MySQL容器重启失败！${NC}"
        fi
    else
        log_write "${GREEN}MySQL容器运行正常${NC}"
    fi
}

# 检测Docker服务状态
check_docker() {
    if ! systemctl is-active --quiet docker; then
        log_write "${RED}Docker服务异常，尝试重启...${NC}"
        sudo systemctl start docker &>/dev/null
        if systemctl is-active --quiet docker; then
            log_write "${GREEN}Docker服务重启成功${NC}"
        else
            log_write "${RED}Docker服务重启失败！${NC}"
        fi
    else
        log_write "${GREEN}Docker服务运行正常${NC}"
    fi
}

# 检测Python博客容器状态
check_blog() {
    if ! command -v docker &>/dev/null; then
        log_write "${YELLOW}Docker未安装，跳过博客容器检测${NC}"
        return
    fi
    if ! docker ps --filter "name=${BLOG_CONTAINER}" --format "{{.Status}}" | grep -q "Up"; then
        log_write "${RED}Python博客容器异常，尝试重启...${NC}"
        docker start ${BLOG_CONTAINER} &>/dev/null
        if docker ps --filter "name=${BLOG_CONTAINER}" --format "{{.Status}}" | grep -q "Up"; then
            log_write "${GREEN}Python博客容器重启成功${NC}"
        else
            log_write "${RED}Python博客容器重启失败！${NC}"
        fi
    else
        log_write "${GREEN}Python博客容器运行正常${NC}"
    fi
}

# 执行检测
log_write "${YELLOW}开始服务状态检测${NC}"
check_nginx
check_mysql
check_docker
check_blog
log_write "${YELLOW}服务状态检测完成，日志保存至${LOG_FILE}${NC}"
