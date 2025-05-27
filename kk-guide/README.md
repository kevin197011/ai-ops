# 运维导航系统 (KK Guide)

一个基于 Ruby Sinatra 的运维导航管理系统，提供前端展示和后台管理功能。

## 功能特性

- 🎯 **分类管理**: 支持自定义导航分类
- 🔗 **链接管理**: 完整的CRUD操作，支持图标、描述、排序
- 🎨 **美观界面**: 现代化的响应式设计，支持浅色主题
- 🔍 **分类过滤**: 支持按分类筛选链接
- ✏️ **在线编辑**: 支持分类和链接的在线编辑
- 🔔 **美化提示**: 统一的操作反馈和通知系统
- 🔐 **权限管理**: 安全的管理员认证系统
- 🐳 **Docker支持**: 完整的容器化部署方案

## 技术栈

- **后端**: Ruby + Sinatra
- **数据库**: SQLite3
- **前端**: HTML + Tailwind CSS + JavaScript
- **容器化**: Docker + Docker Compose
- **反向代理**: Nginx (可选)

## 快速开始

### 方式一：Docker 部署 (推荐)

#### 前置要求
- Docker
- Docker Compose

#### 一键部署
```bash
# 克隆项目
git clone <repository-url>
cd kk-guide

# 运行部署脚本
./docker-deploy.sh
```

部署脚本提供以下选项：
1. **简化部署**: 仅运行应用 (端口 4567)
2. **完整部署**: 应用 + Nginx 反向代理 (端口 80)
3. 查看服务状态
4. 停止服务
5. 清理所有数据

#### 手动 Docker 部署

**简化版本 (仅应用)**:
```bash
# 构建并启动
docker-compose -f docker-compose.simple.yml up -d

# 访问应用
open http://localhost:4567
```

**完整版本 (应用 + Nginx)**:
```bash
# 构建并启动
docker-compose up -d

# 访问应用
open http://localhost
```

### 方式二：本地开发部署

#### 前置要求
- Ruby 2.6+
- Bundler

#### 安装步骤
```bash
# 安装依赖
bundle install

# 启动应用
ruby app.rb

# 访问应用
open http://localhost:4567
```

## 使用说明

### 默认账户
- **用户名**: admin
- **密码**: admin123

### 访问地址
- **前端展示**: `http://localhost:4567/`
- **管理后台**: `http://localhost:4567/admin`

### 主要功能

#### 分类管理
- 添加、编辑、删除导航分类
- 设置分类排序和描述
- 支持在线编辑

#### 链接管理
- 添加、编辑、删除导航链接
- 支持 Emoji 图标选择
- 链接状态切换（启用/禁用）
- 按分类过滤链接
- 支持在线编辑

#### 前端展示
- 响应式卡片布局
- 按分类组织显示
- 仅显示启用的链接
- 现代化的视觉设计

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `RACK_ENV` | development | 运行环境 |
| `SESSION_SECRET` | 自动生成 | 会话密钥 |
| `DATABASE_PATH` | navigation.db | 数据库文件路径 |
| `TZ` | Asia/Shanghai | 时区设置 |

### Docker 配置

#### 数据持久化
数据库文件存储在 `./data` 目录中，通过 Docker volume 挂载实现持久化。

#### 端口配置
- **简化版**: 应用端口 4567
- **完整版**: Nginx 端口 80/443

#### 自定义配置
可以通过修改 `.env` 文件来自定义配置：

```bash
# 复制示例配置
cp .env.example .env

# 编辑配置
vim .env
```

## 开发指南

### 项目结构
```
kk-guide/
├── app.rb                 # 主应用文件
├── Gemfile               # Ruby 依赖
├── views/                # 视图模板
│   ├── layout.erb        # 前端布局
│   ├── index.erb         # 首页
│   ├── admin_layout.erb  # 管理后台布局
│   ├── admin_*.erb       # 管理页面
├── docker-compose.yml    # Docker 编排文件
├── Dockerfile           # Docker 镜像构建
├── nginx/               # Nginx 配置
└── data/                # 数据目录
```

### API 接口

#### 分类管理
- `GET /admin/categories` - 分类列表页面
- `POST /admin/categories` - 创建分类
- `PUT /admin/categories/:id` - 更新分类
- `DELETE /admin/categories/:id` - 删除分类

#### 链接管理
- `GET /admin/links` - 链接列表页面
- `POST /admin/links` - 创建链接
- `PUT /admin/links/:id` - 更新链接
- `PUT /admin/links/:id/toggle` - 切换链接状态
- `DELETE /admin/links/:id` - 删除链接

### 数据库结构

#### categories 表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 |
| name | TEXT | 分类名称 |
| description | TEXT | 分类描述 |
| sort_order | INTEGER | 排序 |
| created_at | DATETIME | 创建时间 |

#### nav_links 表
| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 |
| title | TEXT | 链接标题 |
| url | TEXT | 链接地址 |
| description | TEXT | 链接描述 |
| category_id | INTEGER | 分类ID |
| icon | TEXT | 图标 |
| sort_order | INTEGER | 排序 |
| is_active | BOOLEAN | 是否启用 |
| created_at | DATETIME | 创建时间 |

## 部署建议

### 生产环境
1. 使用完整的 Docker Compose 配置
2. 配置 Nginx 反向代理
3. 设置 SSL 证书
4. 定期备份数据库文件
5. 监控应用健康状态

### 安全建议
1. 修改默认管理员密码
2. 使用强随机会话密钥
3. 配置防火墙规则
4. 定期更新依赖包

### 备份策略
```bash
# 备份数据库
cp data/navigation.db backup/navigation_$(date +%Y%m%d_%H%M%S).db

# 恢复数据库
cp backup/navigation_20231201_120000.db data/navigation.db
```

## 故障排除

### 常见问题

#### 1. 端口被占用
```bash
# 检查端口占用
lsof -i :4567

# 停止占用进程
kill -9 <PID>
```

#### 2. 数据库权限问题
```bash
# 检查数据目录权限
ls -la data/

# 修复权限
chmod 755 data/
chmod 644 data/navigation.db
```

#### 3. Docker 构建失败
```bash
# 清理 Docker 缓存
docker system prune -a

# 重新构建
docker-compose build --no-cache
```

### 日志查看
```bash
# 查看应用日志
docker-compose logs -f navigation-app

# 查看 Nginx 日志
docker-compose logs -f nginx

# 查看所有服务日志
docker-compose logs -f
```

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 更新日志

### v1.0.0
- 初始版本发布
- 基础的分类和链接管理功能
- 响应式前端界面
- Docker 容器化支持
- 完整的管理后台

## 支持

如果您遇到问题或有建议，请：
1. 查看 [FAQ](docs/FAQ.md)
2. 搜索现有的 [Issues](../../issues)
3. 创建新的 Issue

---

**KK Guide Team** - 让运维导航更简单！