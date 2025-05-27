# 智能运维管理平台

基于 Go Gin 和 Tailwind CSS 开发的现代化智能运维管理平台，专注于主机管理和实时监控。

## ✨ 功能特性

### 🎯 仪表盘
- **实时数据展示**：总主机数、在线主机、离线主机数量统计
- **资源监控**：平均资源使用率显示（CPU、内存、磁盘）
- **可视化图表**：
  - 智能主机状态分布饼图（动态过滤空数据）
  - 资源使用率柱状图
  - Chart.js 动画效果和交互式提示
- **自动刷新**：每30秒自动更新数据
- **美观界面**：现代化卡片设计和响应式布局

### 🖥️ 主机管理
- **完整CRUD操作**：主机增删改查
- **实时连通性检测**：一键检查主机状态
- **丰富的主机信息**：
  - 支持自定义端口配置
  - 标签系统（支持多标签）
  - 详细描述和系统信息
- **智能状态管理**：在线/离线/未知状态实时监控
- **搜索和过滤**：按名称、IP、状态快速筛选
- **响应式表格**：移动端友好的数据展示

### 🎨 用户界面设计
- **现代化左侧导航栏**：
  - 清晰的功能分区
  - 活跃状态指示
  - 可点击Logo返回首页
  - 底部用户信息展示
- **高级通知系统**：
  - 4种通知类型（成功、错误、警告、信息）
  - 顶部中心位置显示
  - 自动消失和手动关闭
  - 平滑动画效果和进度条
- **交互式确认对话框**：替代原生浏览器弹窗
- **加载状态管理**：操作过程中的loading提示
- **一致性设计语言**：统一的色彩方案和字体规范

### 🔧 技术亮点
- **智能图表渲染**：只显示有数据的图表部分，避免空白扇形
- **错误处理机制**：完善的异常捕获和用户友好提示
- **代码优化**：解决了JavaScript变量冲突和执行顺序问题
- **API调试工具**：内置测试页面，便于开发和调试

## 🛠️ 技术栈

### 后端技术
- **Go 1.24.1** - 主要编程语言
- **Gin Framework** - 高性能Web框架
- **SQLite** - 轻量级数据库存储
- **HTML Templates** - 服务端模板渲染

### 前端技术
- **Tailwind CSS** - 原子化CSS框架
- **Chart.js** - 专业图表可视化库
- **Font Awesome 6.0** - 图标库
- **Vanilla JavaScript** - 原生JS交互
- **响应式设计** - 移动端适配

### 架构特点
- **分层架构**：Repository -> Service -> Handler 清晰分层
- **RESTful API**：标准化API接口设计
- **CORS支持**：跨域请求处理
- **模块化组件**：可复用的通知和对话框组件

## 📁 项目结构

```
ai-ops/
├── main.go                 # 主程序入口
├── go.mod                  # Go 模块文件
├── README.md              # 项目说明文档
├── data/                  # 数据库文件目录
│   └── ai-ops.db         # SQLite 数据库
├── internal/              # 内部包目录
│   ├── database/          # 数据库配置
│   │   └── sqlite.go     # SQLite 初始化
│   ├── repository/        # 数据仓库层
│   │   └── host_repository.go
│   ├── handlers/          # HTTP 处理器
│   │   └── host_handler.go
│   ├── services/          # 业务逻辑层
│   │   └── host_service.go
│   ├── middleware/        # 中间件
│   │   └── cors.go       # 跨域处理
│   └── models/            # 数据模型
│       └── host.go       # 主机模型定义
└── web/                   # 前端资源
    ├── templates/         # HTML 模板
    │   ├── dashboard.html # 仪表盘页面
    │   ├── hosts.html    # 主机管理页面
    │   └── test-api.html # API测试页面
    └── static/            # 静态资源
        └── js/
            └── notification.js # 通知系统
```

## 🚀 快速开始

### 前置要求
- Go 1.24.1 或更高版本
- 现代浏览器（支持ES6+）

### 安装运行

1. **克隆项目**
```bash
git clone <repository-url>
cd ai-ops
```

2. **安装依赖**
```bash
go mod tidy
```

3. **构建运行**
```bash
# 开发模式
go run main.go

# 或者构建后运行
go build -o ai-ops .
./ai-ops
```

4. **访问应用**
- 🏠 仪表盘：http://localhost:8080
- 🖥️ 主机管理：http://localhost:8080/hosts
- 🧪 API测试：http://localhost:8080/test

## 📊 API 接口

### 主机管理接口
| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/v1/hosts` | 获取主机列表 |
| `POST` | `/api/v1/hosts` | 创建新主机 |
| `GET` | `/api/v1/hosts/:id` | 获取单个主机详情 |
| `PUT` | `/api/v1/hosts/:id` | 更新主机信息 |
| `DELETE` | `/api/v1/hosts/:id` | 删除指定主机 |
| `POST` | `/api/v1/hosts/:id/check` | 检查主机连通性 |

### 仪表盘接口
| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/v1/dashboard/stats` | 获取仪表盘统计数据 |

### API响应格式
```json
{
  "data": {
    "total_hosts": 4,
    "online_hosts": 0,
    "offline_hosts": 3,
    "cpu_average": 45.5,
    "memory_average": 62.3,
    "disk_average": 38.7
  }
}
```

## 📋 数据模型

### Host 主机模型
```go
type Host struct {
    ID          string     `json:"id"`          // 主机唯一标识
    Name        string     `json:"name"`        // 主机名称
    IP          string     `json:"ip"`          // IP地址
    Port        int        `json:"port"`        // 连接端口
    OS          string     `json:"os"`          // 操作系统
    CPU         string     `json:"cpu"`         // CPU信息
    Memory      string     `json:"memory"`      // 内存信息
    Disk        string     `json:"disk"`        // 磁盘信息
    Status      HostStatus `json:"status"`      // 主机状态
    Description string     `json:"description"` // 描述信息
    Tags        []string   `json:"tags"`        // 标签列表
    CreatedAt   time.Time  `json:"created_at"`  // 创建时间
    UpdatedAt   time.Time  `json:"updated_at"`  // 更新时间
    LastCheck   time.Time  `json:"last_check"`  // 最后检查时间
}
```

### 主机状态枚举
- `online` - 在线状态
- `offline` - 离线状态
- `unknown` - 未知状态

## 🎯 核心功能演示

### 智能通知系统
```javascript
// 使用全局通知实例
notification.success('操作成功！');
notification.error('操作失败，请重试');
notification.warning('警告信息');
notification.info('提示信息');
```

### 确认对话框
```javascript
const confirmed = await ConfirmDialog.show(
    '删除确认',
    '确定要删除这台主机吗？',
    '删除',
    '取消'
);
```

### 加载状态管理
```javascript
loading.show('正在处理...');
// 执行异步操作
loading.hide();
```

## 🔧 开发说明

### 添加新功能
1. 在 `internal/models/` 中定义数据模型
2. 在 `internal/repository/` 中实现数据访问层
3. 在 `internal/services/` 中编写业务逻辑
4. 在 `internal/handlers/` 中添加HTTP处理器
5. 在 `main.go` 中注册新路由
6. 在 `web/templates/` 中创建前端页面

### 自定义配置建议
- **生产环境**：集成MySQL/PostgreSQL数据库
- **安全性**：添加JWT认证和RBAC权限控制
- **监控**：集成Prometheus指标监控
- **日志**：使用结构化日志记录
- **缓存**：Redis缓存热点数据
- **容器化**：Docker镜像和K8s部署

### 代码规范
- 遵循Go官方代码规范
- 使用gofmt格式化代码
- 添加适当的注释和文档
- 错误处理要完整和用户友好

## 🗺️ 后续规划

### 短期目标
- [ ] 用户认证和权限管理
- [ ] 监控告警功能
- [ ] 批量操作支持
- [ ] 数据导入导出
- [ ] 国际化支持

### 中期目标
- [ ] 容器和K8s集群管理
- [ ] 自动化运维脚本执行
- [ ] 性能指标收集和分析
- [ ] 日志聚合和搜索
- [ ] 移动端App

### 长期愿景
- [ ] AI智能运维助手
- [ ] 多云环境管理
- [ ] DevOps工具链集成
- [ ] 企业级高可用架构
- [ ] 插件系统和开放API

## 🤝 贡献指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📸 界面预览

### 仪表盘界面
- 现代化左侧导航栏
- 实时数据统计卡片
- 交互式图表展示
- 智能通知系统

### 主机管理界面
- 响应式数据表格
- 模态框表单操作
- 状态颜色指示
- 快速搜索过滤

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

如有问题或建议，请：
- 创建 GitHub Issue
- 提交 Pull Request
- 联系项目维护者

---

**智能运维管理平台** - 让运维更简单、更智能、更高效！ 🚀