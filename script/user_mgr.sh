#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $UID -ne 0 ]; then
    echo -e "${RED}错误：需以Root用户执行此脚本！${NC}"
    exit 1
fi

echo -e "${YELLOW}===== 运维用户管理模块 =====${NC}"
echo "1. 批量创建运维用户"
echo "2. 删除指定运维用户"
echo "3. 为用户分配sudo免密权限"
read -p "请选择操作（1-3）：" opt

case $opt in
    1)
        read -p "请输入要创建的用户名（多个用空格分隔）：" users
        groupadd -f ops &>/dev/null
        for user in $users; do
            if id $user &>/dev/null; then
                echo -e "${YELLOW}用户${user}已存在，跳过...${NC}"
            else
                useradd -m -s /bin/bash -G ops $user &>/dev/null
                echo "$user:Ops@123456" | chpasswd &>/dev/null
                chage -d 0 $user &>/dev/null
                echo -e "${GREEN}用户${user}创建成功！初始密码：Ops@123456（首次登录需修改）${NC}"
            fi
        done
        ;;
    2)
        read -p "请输入要删除的用户名（多个用空格分隔）：" users
        for user in $users; do
            if id $user &>/dev/null; then
                userdel -r $user &>/dev/null
                echo -e "${GREEN}用户${user}已删除${NC}"
            else
                echo -e "${YELLOW}用户${user}不存在，跳过...${NC}"
            fi
        done
        ;;
    3)
        read -p "请输入要分配sudo权限的用户名：" user
        if id $user &>/dev/null; then
            echo "${user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ops_${user}
            chmod 0440 /etc/sudoers.d/ops_${user}
            echo -e "${GREEN}用户${user}已获得sudo免密权限${NC}"
        else
            echo -e "${RED}用户${user}不存在！${NC}"
        fi
        ;;
    *)
        echo -e "${RED}输入无效！请选择1-3${NC}"
        ;;
esac

