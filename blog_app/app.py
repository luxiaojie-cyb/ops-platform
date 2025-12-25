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
