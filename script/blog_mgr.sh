#!/bin/bash
OPS_DIR="/home/lu/ops_platform"
BLOG_DIR="${OPS_DIR}/blog_app"
IMAGE_NAME="python-blog:v1.0"
CONTAINER_NAME="python-blog"
PORT="5000:5000"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_blog_dir() {
    if [ ! -d ${BLOG_DIR} ]; then
        echo -e "${RED}错误：博客应用目录${BLOG_DIR}不存在${NC}"
        exit 1
    fi
}

echo -e "${YELLOW}===== Python Flask博客运维模块 =====${NC}"
echo "1. 初始化博客代码（自动写入配置/代码）"
echo "2. 构建博客Docker镜像"
echo "3. 启动博客容器"
echo "4. 停止/重启博客容器"
echo "5. 查看博客容器日志"
read -p "请选择操作（1-5）：" opt

case $opt in
    1)
        echo -e "${YELLOW}正在初始化博客代码...${NC}"
        cat > ${BLOG_DIR}/app.py << 'EOF2'
from flask import Flask, render_template, request, redirect, url_for, session, flash
import os
from datetime import datetime

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY') or 'dev_secret_key_123456'

posts = [
    {
        "id": 1,
        "title": "Docker部署Python Flask应用",
        "content": "使用Dockerfile构建镜像，一键启动容器，实现Python应用的快速部署和迁移。",
        "create_time": "2025-12-25 10:00"
    },
    {
        "id": 2,
        "title": "Ubuntu 22.04 Shell运维脚本编写",
        "content": "通过Shell脚本实现服务监控、用户管理、Docker容器自动化运维，提升工作效率。",
        "create_time": "2025-12-25 11:00"
    }
]

ADMIN_USER = "admin"
ADMIN_PWD = "admin123"

@app.route('/')
def index():
    return render_template('index.html', posts=posts)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        if username == ADMIN_USER and password == ADMIN_PWD:
            session['is_login'] = True
            flash('登录成功！', 'success')
            return redirect(url_for('index'))
        else:
            flash('账号或密码错误！', 'danger')
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('is_login', None)
    flash('已退出登录！', 'info')
    return redirect(url_for('index'))

@app.route('/add', methods=['GET', 'POST'])
def add_post():
    if not session.get('is_login'):
        flash('请先登录！', 'warning')
        return redirect(url_for('login'))
    if request.method == 'POST':
        title = request.form.get('title')
        content = request.form.get('content')
        if not title or not content:
            flash('标题和内容不能为空！', 'danger')
            return render_template('post.html', action="新增")
        new_id = max([p['id'] for p in posts]) + 1 if posts else 1
        new_post = {
            "id": new_id,
            "title": title,
            "content": content,
            "create_time": datetime.now().strftime("%Y-%m-%d %H:%M")
        }
        posts.append(new_post)
        flash('文章新增成功！', 'success')
        return redirect(url_for('index'))
    return render_template('post.html', action="新增")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF2
        cat > ${BLOG_DIR}/requirements.txt << 'EOF2'
flask==2.3.3
werkzeug==2.3.7
EOF2
        cat > ${BLOG_DIR}/Dockerfile << 'EOF2'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
EOF2
        cat > ${BLOG_DIR}/templates/base.html << 'EOF2'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}我的运维博客{% endblock %}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
</head>
<body>
    <header class="header">
        <div class="container">
            <h1><a href="/">运维技术博客</a></h1>
            <nav>
                {% if session.is_login %}
                    <a href="/add">新增文章</a>
                    <a href="/logout">退出登录</a>
                {% else %}
                    <a href="/login">管理员登录</a>
                {% endif %}
            </nav>
        </div>
    </header>
    <main class="container main">
        {% with messages = get_flashed_messages(with_categories=true) %}
            {% if messages %}
                {% for category, msg in messages %}
                    <div class="alert alert-{{ category }}">{{ msg }}</div>
                {% endfor %}
            {% endif %}
        {% endwith %}
        {% block content %}{% endblock %}
    </main>
    <footer class="footer">
        <div class="container">
            <p>© 2025 运维技术博客 | 基于Python Flask + Docker构建</p>
        </div>
    </footer>
</body>
</html>
EOF2
        cat > ${BLOG_DIR}/templates/index.html << 'EOF2'
{% extends "base.html" %}
{% block content %}
    <div class="post-list">
        {% if posts %}
            {% for post in posts %}
                <div class="post-item">
                    <h2 class="post-title">{{ post.title }}</h2>
                    <div class="post-meta">{{ post.create_time }}</div>
                    <div class="post-content">{{ post.content }}</div>
                </div>
            {% endfor %}
        {% else %}
            <div class="empty">暂无文章，快去新增吧！</div>
        {% endif %}
    </div>
{% endblock %}
EOF2
        cat > ${BLOG_DIR}/templates/login.html << 'EOF2'
{% extends "base.html" %}
{% block title %}登录 - 运维技术博客{% endblock %}
{% block content %}
    <div class="login-form">
        <h2>管理员登录</h2>
        <form method="post">
            <div class="form-group">
                <label for="username">账号：</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">密码：</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit" class="btn">登录</button>
        </form>
    </div>
{% endblock %}
EOF2
        cat > ${BLOG_DIR}/templates/post.html << 'EOF2'
{% extends "base.html" %}
{% block title %}{{ action }}文章 - 运维技术博客{% endblock %}
{% block content %}
    <div class="post-form">
        <h2>{{ action }}文章</h2>
        <form method="post">
            <div class="form-group">
                <label for="title">文章标题：</label>
                <input type="text" id="title" name="title" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="content">文章内容：</label>
                <textarea id="content" name="content" class="form-control" rows="8" required></textarea>
            </div>
            <button type="submit" class="btn">提交</button>
        </form>
    </div>
{% endblock %}
EOF2
        cat > ${BLOG_DIR}/static/css/style.css << 'EOF2'
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}
body {
    font-family: "Microsoft YaHei", sans-serif;
    line-height: 1.6;
    color: #333;
    background-color: #f5f5f5;
}
.container {
    width: 80%;
    max-width: 1000px;
    margin: 0 auto;
    padding: 0 20px;
}
.header {
    background-color: #2c3e50;
    color: white;
    padding: 20px 0;
    margin-bottom: 30px;
}
.header h1 a {
    color: white;
    text-decoration: none;
}
.header nav {
    margin-top: 10px;
}
.header nav a {
    color: white;
    text-decoration: none;
    margin-right: 20px;
}
.header nav a:hover {
    text-decoration: underline;
}
.main {
    min-height: 60vh;
}
.alert {
    padding: 15px;
    margin-bottom: 20px;
    border-radius: 4px;
}
.alert-success {
    background-color: #d4edda;
    color: #155724;
}
.alert-danger {
    background-color: #f8d7da;
    color: #721c24;
}
.alert-warning {
    background-color: #fff3cd;
    color: #856404;
}
.alert-info {
    background-color: #d1ecf1;
    color: #0c5460;
}
.post-list {
    margin-top: 20px;
}
.post-item {
    background-color: white;
    padding: 20px;
    margin-bottom: 20px;
    border-radius: 4px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
.post-title {
    color: #2c3e50;
    margin-bottom: 10px;
}
.post-meta {
    color: #999;
    font-size: 0.9em;
    margin-bottom: 15px;
}
.post-content {
    line-height: 1.8;
}
.empty {
    text-align: center;
    padding: 50px;
    color: #999;
    font-size: 1.2em;
}
.login-form, .post-form {
    background-color: white;
    padding: 30px;
    border-radius: 4px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    max-width: 600px;
    margin: 0 auto;
}
.login-form h2, .post-form h2 {
    margin-bottom: 20px;
    color: #2c3e50;
    text-align: center;
}
.form-group {
    margin-bottom: 20px;
}
.form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: bold;
}
.form-group input, .form-group textarea {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1em;
}
.btn {
    display: inline-block;
    background-color: #2c3e50;
    color: white;
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1em;
}
.btn:hover {
    background-color: #34495e;
}
.footer {
    background-color: #2c3e50;
    color: white;
    text-align: center;
    padding: 20px 0;
    margin-top: 50px;
}
EOF2
        echo -e "${GREEN}博客代码初始化完成，路径：${BLOG_DIR}${NC}"
        ;;
    2)
        check_blog_dir
        echo -e "${YELLOW}正在构建博客镜像${IMAGE_NAME}...${NC}"
        cd ${BLOG_DIR}
        docker build -t ${IMAGE_NAME} . &>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}博客镜像${IMAGE_NAME}构建成功${NC}"
        else
            echo -e "${RED}镜像构建失败！请检查Dockerfile或代码${NC}"
        fi
        ;;
    3)
        check_blog_dir
        if ! docker ps --filter "name=${CONTAINER_NAME}" | grep -q ${CONTAINER_NAME}; then
            docker run -d --name ${CONTAINER_NAME} -p ${PORT} --restart=always ${IMAGE_NAME} &>/dev/null
            echo -e "${GREEN}博客容器${CONTAINER_NAME}启动成功！访问地址：http://$(hostname -I | awk '{print $1}'):5000${NC}"
        else
            echo -e "${YELLOW}博客容器${CONTAINER_NAME}已运行${NC}"
        fi
        ;;
    4)
        read -p "请输入操作（stop/restart）：" op
        if docker ps -a --filter "name=${CONTAINER_NAME}" | grep -q ${CONTAINER_NAME}; then
            docker ${op} ${CONTAINER_NAME} &>/dev/null
            echo -e "${GREEN}博客容器已${op}${NC}"
        else
            echo -e "${RED}博客容器${CONTAINER_NAME}不存在${NC}"
        fi
        ;;
    5)
        if docker ps -a --filter "name=${CONTAINER_NAME}" | grep -q ${CONTAINER_NAME}; then
            echo -e "${YELLOW}博客容器实时日志（按Ctrl+C退出）：${NC}"
            docker logs -f ${CONTAINER_NAME}
        else
            echo -e "${RED}博客容器${CONTAINER_NAME}不存在${NC}"
        fi
        ;;
    *)
        echo -e "${RED}输入无效！请选择1-5${NC}"
        ;;
esac
