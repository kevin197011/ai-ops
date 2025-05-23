#!/bin/bash

lsof -i :8080 -t | xargs kill -9


echo "==================================="
echo "    智能运维管理平台启动脚本"
echo "==================================="

# 检查Go环境
if ! command -v go &> /dev/null; then
    echo "❌ Go 环境未安装，请先安装 Go"
    exit 1
fi

echo "✅ Go 环境检查通过"

# 安装依赖
echo "📦 正在安装依赖..."
go mod tidy

if [ $? -ne 0 ]; then
    echo "❌ 依赖安装失败"
    exit 1
fi

echo "✅ 依赖安装完成"

# 编译项目
echo "🔨 正在编译项目..."
go build -o ai-ops main.go

if [ $? -ne 0 ]; then
    echo "❌ 项目编译失败"
    exit 1
fi

echo "✅ 项目编译完成"

# 启动服务
echo "🚀 正在启动服务..."
echo ""
echo "访问地址:"
echo "  仪表盘: http://localhost:8080"
echo "  主机管理: http://localhost:8080/hosts"
echo ""
echo "API 接口:"
echo "  GET  /api/v1/hosts           - 获取主机列表"
echo "  POST /api/v1/hosts           - 创建主机"
echo "  GET  /api/v1/hosts/:id       - 获取主机详情"
echo "  PUT  /api/v1/hosts/:id       - 更新主机"
echo "  DELETE /api/v1/hosts/:id     - 删除主机"
echo "  POST /api/v1/hosts/:id/check - 检查主机连通性"
echo "  GET  /api/v1/dashboard/stats - 获取仪表盘统计"
echo ""
echo "按 Ctrl+C 停止服务"
echo "==================================="

./ai-ops