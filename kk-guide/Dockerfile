# 使用官方Ruby镜像作为基础镜像
FROM ruby:3.1-slim

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    sqlite3 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 设置时区为中国时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 复制Gemfile
COPY Gemfile ./

# 安装Ruby依赖
RUN bundle install --without development test

# 复制应用代码
COPY . .

# 创建数据目录
RUN mkdir -p /app/data

# 设置数据库文件路径环境变量
ENV DATABASE_PATH=/app/data/navigation.db

# 暴露端口
EXPOSE 4567

# 创建非root用户
RUN groupadd -g 1000 appuser && \
    useradd -r -u 1000 -g appuser appuser && \
    chown -R appuser:appuser /app

# 切换到非root用户
USER appuser

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:4567/ || exit 1

# 启动应用
CMD ["ruby", "app.rb", "-o", "0.0.0.0"]