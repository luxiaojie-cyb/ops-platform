#!/bin/bash
OPS_DIR="/home/lu/ops_platform"
GIT_REPO_URL="https://github.com/yourname/ops-platform.git" # 替换为你的远程仓库
GIT_BRANCH="main"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查Git是否安装
if ! command -v git &>/dev/null; then
    echo -e "${YELLOW}Git未安装，正在自动安装...${NC}"
    sudo apt update &>/dev/null
    sudo apt install -y git &>/dev/null
    echo -e "${GREEN}Git安装完成${NC}"
fi

# 初始化仓库（若未初始化）
if [ ! -d ${OPS_DIR}/.git ]; then
    cd ${OPS_DIR}
    git init &>/dev/null
    git remote add origin ${GIT_REPO_URL} &>/dev/null
    echo -e "${YELLOW}已在${OPS_DIR}初始化Git仓库，并关联远程仓库${GIT_REPO_URL}${NC}"
fi

cd ${OPS_DIR}

# 菜单界面
clear
echo -e "${GREEN}==================== Git版本同步 ====================${NC}"
echo "1. 拉取远程仓库最新代码"
echo "2. 提交本地脚本到远程仓库"
echo "3. 切换Git分支"
echo "4. 查看仓库状态"
echo "5. 返回主菜单"
echo -e "${GREEN}=====================================================${NC}"
read -p "请输入操作序号（1-5）：" opt

case $opt in
    1)
        # 拉取远程代码
        echo -e "${YELLOW}正在拉取${GIT_BRANCH}分支最新代码...${NC}"
        git pull origin ${GIT_BRANCH}
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}拉取远程代码成功${NC}"
        else
            echo -e "${RED}拉取失败，请检查远程仓库连接${NC}"
        fi
        ;;
    2)
        # 提交本地代码
        read -p "请输入提交备注：" commit_msg
        git add . &>/dev/null
        git commit -m "${commit_msg}" &>/dev/null
        git push origin ${GIT_BRANCH}
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}本地代码已成功推送到远程仓库${NC}"
        else
            echo -e "${RED}推送失败，请检查仓库权限或网络${NC}"
        fi
        ;;
    3)
        # 切换分支
        read -p "请输入要切换的分支名：" branch
        git checkout ${branch} &>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}已切换到${branch}分支${NC}"
        else
            echo -e "${RED}分支${branch}不存在，是否创建？(y/n)："
            read ans
            if [ "$ans" = "y" ]; then
                git checkout -b ${branch} &>/dev/null
                echo -e "${GREEN}已创建并切换到${branch}分支${NC}"
            fi
        fi
        ;;
    4)
        # 查看仓库状态
        echo -e "${YELLOW}===== Git仓库状态 =====${NC}"
        git status
        echo -e "${YELLOW}\n===== 本地分支 =====${NC}"
        git branch
        echo -e "${YELLOW}\n===== 远程分支 =====${NC}"
        git branch -r
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
