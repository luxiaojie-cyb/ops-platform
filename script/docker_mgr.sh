#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${YELLOW}Docker未安装，正在自动安装...${NC}"
        sudo apt update &>/dev/null
        sudo apt install -y docker.io docker-compose &>/dev/null
        sudo systemctl enable --now docker &>/dev/null
        sudo usermod -aG docker $USER &>/dev/null
        echo -e "${GREEN}Docker安装完成，需重新登录生效docker组权限${NC}"
    fi
}
check_docker

echo -e "${YELLOW}===== Docker容器通用管理模块 =====${NC}"
echo "1. 启动MySQL容器（带数据卷）"
echo "2. 容器启动/停止/重启"
echo "3. 查看容器资源占用"
echo "4. 镜像拉取/删除"
echo "5. 查看所有容器状态"
read -p "请选择操作（1-5）：" opt

case $opt in
    1)
        if ! docker ps --filter "name=mysql" | grep -q mysql; then
            docker run -d --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=Root@123456 -v mysql_data:/var/lib/mysql --restart=always mysql:8.0 &>/dev/null
            echo -e "${GREEN}MySQL容器启动成功！密码：Root@123456，数据卷：mysql_data${NC}"
        else
            echo -e "${YELLOW}MySQL容器已运行${NC}"
        fi
        ;;
    2)
        read -p "请输入容器名：" cname
        read -p "请输入操作（start/stop/restart）：" op
        if docker ps -a --filter "name=${cname}" | grep -q ${cname}; then
            docker ${op} ${cname} &>/dev/null
            echo -e "${GREEN}容器${cname}已执行${op}操作${NC}"
        else
            echo -e "${RED}容器${cname}不存在${NC}"
        fi
        ;;
    3)
        echo -e "${YELLOW}容器实时资源占用（按Ctrl+C退出）：${NC}"
        docker stats --no-stream
        ;;
    4)
        read -p "操作类型（pull/rm）：" op
        if [ "$op" = "pull" ]; then
            read -p "镜像名（如nginx:latest）：" img
            docker pull $img &>/dev/null
            echo -e "${GREEN}镜像${img}拉取完成${NC}"
        elif [ "$op" = "rm" ]; then
            read -p "镜像ID/名称：" img
            docker rmi $img &>/dev/null
            echo -e "${GREEN}镜像${img}删除完成${NC}"
        else
            echo -e "${RED}仅支持pull/rm操作${NC}"
        fi
        ;;
    5)
        echo -e "${YELLOW}所有容器状态：${NC}"
        docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    *)
        echo -e "${RED}输入无效！请选择1-5${NC}"
        ;;
esac
