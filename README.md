# 智能运维管理平台

基于 Go Gin 和 Tailwind CSS 开发的现代化智能运维管理平台，专注于主机管理和实时监控。

## 功能特性

### 🎯 仪表盘
- 实时统计总主机数、在线主机、离线主机数量
- 平均资源使用率显示（CPU、内存、磁盘）
- 主机状态分布饼图
- 资源使用率柱状图
- 自动数据刷新（30秒间隔）

### 🖥️ 主机管理
- 主机增删改查操作
- 主机连通性检测
- 支持自定义端口、标签、描述
- 实时状态监控（在线/离线/未知）
- 响应式表格设计
- 模态框表单操作

### 🎨 用户界面
- 现代化 Tailwind CSS 设计
- 响应式布局，支持移动端
- Font Awesome 图标库
- Chart.js 图表可视化
- 直观的状态指示器

## 技术栈

### 后端
- **Go 1.24.1** - 主要编程语言
- **Gin** - Web 框架
- **SQLite** - 数据库存储
- **HTML Templates** - 模板引擎

### 前端
- **Tailwind CSS** - UI 框架
- **Chart.js** - 图表库
- **Font Awesome** - 图标库
- **Vanilla JavaScript** - 前端交互

## 项目结构

```
ai-ops/
├── main.go                 # 主程序入口
├── go.mod                  # Go 模块文件
├── README.md              # 项目说明
├── start.sh               # 启动脚本
├── data/                  # 数据库文件目录
│   └── ai-ops.db         # SQLite 数据库
├── internal/              # 内部包
│   ├── database/          # 数据库配置
│   │   └── sqlite.go
│   ├── repository/        # 数据仓库层
│   │   └── host_repository.go
│   ├── handlers/          # HTTP 处理器
│   │   └── host_handler.go
│   ├── services/          # 业务逻辑层
│   │   └── host_service.go
│   ├── middleware/        # 中间件
│   │   └── cors.go
│   └── models/            # 数据模型
│       └── host.go
└── web/                   # 前端资源
    ├── templates/         # HTML 模板
    │   ├── dashboard.html
    │   └── hosts.html
    └── static/            # 静态资源
        ├── css/
        └── js/
```

## 快速开始

### 前置要求
- Go 1.24.1 或更高版本
- 现代浏览器

### 安装运行

1. 克隆项目
```bash
git clone <repository-url>
cd ai-ops
```

2. 安装依赖
```bash
go mod tidy
```

3. 运行程序
```bash
go run main.go
```

4. 访问应用
- 仪表盘: http://localhost:8080
- 主机管理: http://localhost:8080/hosts

## API 接口

### 主机管理
- `GET /api/v1/hosts` - 获取主机列表
- `POST /api/v1/hosts` - 创建主机
- `GET /api/v1/hosts/:id` - 获取单个主机
- `PUT /api/v1/hosts/:id` - 更新主机
- `DELETE /api/v1/hosts/:id` - 删除主机
- `POST /api/v1/hosts/:id/check` - 检查主机连通性

### 仪表盘
- `GET /api/v1/dashboard/stats` - 获取仪表盘统计数据

## 数据模型

### Host 主机模型
```go
type Host struct {
    ID          string     `json:"id"`
    Name        string     `json:"name"`
    IP          string     `json:"ip"`
    Port        int        `json:"port"`
    OS          string     `json:"os"`
    CPU         string     `json:"cpu"`
    Memory      string     `json:"memory"`
    Disk        string     `json:"disk"`
    Status      HostStatus `json:"status"`
    Description string     `json:"description"`
    Tags        []string   `json:"tags"`
    CreatedAt   time.Time  `json:"created_at"`
    UpdatedAt   time.Time  `json:"updated_at"`
    LastCheck   time.Time  `json:"last_check"`
}
```

### 主机状态
- `online` - 在线
- `offline` - 离线
- `unknown` - 未知

## 开发说明

### 添加新功能
1. 在 `internal/models/` 中定义数据模型
2. 在 `internal/services/` 中实现业务逻辑
3. 在 `internal/handlers/` 中添加 HTTP 处理器
4. 在 `main.go` 中注册路由
5. 在 `web/templates/` 中创建前端页面

### 自定义配置
当前版本使用内存存储，生产环境建议：
- 集成数据库（MySQL/PostgreSQL）
- 添加认证授权
- 配置文件管理
- 日志系统
- 监控告警

## 后续规划

- [ ] 数据库持久化
- [ ] 用户认证系统
- [ ] 监控告警功能
- [ ] 批量操作
- [ ] 导入导出功能
- [ ] 性能优化
- [ ] Docker 容器化
- [ ] 集群管理
- [ ] 自动化运维脚本

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交变更
4. 推送到分支
5. 创建 Pull Request

## 许可证

MIT License

## 联系方式

如有问题或建议，请创建 Issue 或联系项目维护者。