# Docker 部署指南

## 快速开始

### 1. 一键部署（推荐）

```bash
# 运行部署脚本
./docker-deploy.sh
```

脚本会自动：
- 检查 Docker 环境
- 创建必要目录
- 生成安全配置
- 提供部署选项

### 2. 手动部署

#### 简化版本（仅应用）

```bash
# 构建并启动
docker-compose -f docker-compose.simple.yml up -d

# 查看状态
docker-compose -f docker-compose.simple.yml ps

# 查看日志
docker-compose -f docker-compose.simple.yml logs -f
```

访问地址：http://localhost:4567

#### 完整版本（应用 + Nginx）

```bash
# 构建并启动
docker-compose up -d

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

访问地址：http://localhost

## 配置说明

### 环境变量配置

```bash
# 复制示例配置
cp env.example .env

# 编辑配置
vim .env
```

重要配置项：
- `SESSION_SECRET`: 会话密钥（生产环境必须修改）
- `DATABASE_PATH`: 数据库文件路径
- `TZ`: 时区设置

### 数据持久化

数据库文件存储在 `./data` 目录：
```bash
# 查看数据文件
ls -la data/

# 备份数据
cp data/navigation.db backup/
```

### 端口配置

| 服务 | 简化版 | 完整版 |
|------|--------|--------|
| 应用 | 4567 | - |
| Nginx | - | 80, 443 |

## 常用命令

### 服务管理

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看状态
docker-compose ps

# 查看日志
docker-compose logs -f [service_name]
```

### 镜像管理

```bash
# 构建镜像
docker-compose build

# 强制重新构建
docker-compose build --no-cache

# 拉取最新镜像
docker-compose pull
```

### 数据管理

```bash
# 备份数据库
docker-compose exec navigation-app cp /app/data/navigation.db /app/data/backup_$(date +%Y%m%d_%H%M%S).db

# 进入容器
docker-compose exec navigation-app /bin/sh

# 查看容器内文件
docker-compose exec navigation-app ls -la /app/data/
```

## 故障排除

### 常见问题

#### 1. 端口冲突
```bash
# 检查端口占用
lsof -i :4567
lsof -i :80

# 修改端口（在 docker-compose.yml 中）
ports:
  - "8080:4567"  # 改为 8080 端口
```

#### 2. 权限问题
```bash
# 修复数据目录权限
sudo chown -R 1000:1000 data/
chmod 755 data/
```

#### 3. 容器无法启动
```bash
# 查看详细错误
docker-compose logs navigation-app

# 检查配置文件
docker-compose config

# 重新构建
docker-compose build --no-cache
```

#### 4. 数据库连接失败
```bash
# 检查数据库文件
ls -la data/navigation.db

# 重新初始化数据库
rm data/navigation.db
docker-compose restart navigation-app
```

### 日志分析

```bash
# 查看应用日志
docker-compose logs -f navigation-app

# 查看 Nginx 日志
docker-compose logs -f nginx

# 查看最近 100 行日志
docker-compose logs --tail=100 navigation-app

# 查看特定时间的日志
docker-compose logs --since="2023-12-01T10:00:00" navigation-app
```

## 生产环境部署

### 安全配置

1. **修改默认密码**
   ```bash
   # 登录管理后台修改密码
   # 或删除数据库重新初始化
   ```

2. **使用强会话密钥**
   ```bash
   # 生成随机密钥
   openssl rand -base64 32

   # 更新 .env 文件
   SESSION_SECRET=生成的密钥
   ```

3. **配置防火墙**
   ```bash
   # 只开放必要端口
   ufw allow 80
   ufw allow 443
   ufw deny 4567  # 如果使用 Nginx 代理
   ```

### SSL 配置

1. **获取 SSL 证书**
   ```bash
   # 使用 Let's Encrypt
   certbot certonly --webroot -w /var/www/html -d your-domain.com
   ```

2. **配置 Nginx SSL**
   ```bash
   # 编辑 nginx/nginx.conf
   # 取消注释 HTTPS 服务器配置
   # 更新证书路径
   ```

3. **更新 docker-compose.yml**
   ```yaml
   volumes:
     - /etc/letsencrypt:/etc/nginx/ssl:ro
   ```

### 监控和备份

1. **健康检查**
   ```bash
   # 检查服务状态
   curl -f http://localhost/health || echo "Service down"
   ```

2. **自动备份**
   ```bash
   # 添加到 crontab
   0 2 * * * /path/to/backup-script.sh
   ```

3. **日志轮转**
   ```bash
   # 配置 logrotate
   /var/log/navigation/*.log {
       daily
       rotate 30
       compress
       delaycompress
       missingok
       notifempty
   }
   ```

## 升级指南

### 应用升级

```bash
# 1. 备份数据
cp data/navigation.db backup/

# 2. 拉取最新代码
git pull origin main

# 3. 重新构建
docker-compose build

# 4. 重启服务
docker-compose down
docker-compose up -d

# 5. 验证服务
docker-compose ps
curl -f http://localhost/
```

### 回滚操作

```bash
# 1. 停止服务
docker-compose down

# 2. 恢复代码
git checkout previous-version

# 3. 恢复数据库
cp backup/navigation.db data/

# 4. 重新部署
docker-compose up -d
```

## 性能优化

### 资源限制

```yaml
# 在 docker-compose.yml 中添加
services:
  navigation-app:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
```

### 缓存配置

```yaml
# Nginx 缓存配置
location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

## 开发环境

### 本地开发

```bash
# 使用开发配置
docker-compose -f docker-compose.dev.yml up -d

# 挂载代码目录
volumes:
  - .:/app
  - /app/vendor/bundle
```

### 调试模式

```bash
# 启用调试日志
docker-compose exec navigation-app tail -f /app/logs/debug.log

# 进入容器调试
docker-compose exec navigation-app /bin/sh
```

## 支持

如果遇到问题：
1. 查看本指南的故障排除部分
2. 检查 GitHub Issues
3. 提交新的 Issue 并附上日志信息

---

**提示**: 生产环境部署前请仔细阅读安全配置部分！