#!/bin/bash

# 运维导航系统 Docker 部署脚本
# 作者: KK Guide Team
# 版本: 1.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  运维导航系统 Docker 部署${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi

    print_message "Docker 环境检查通过"
}

# 创建必要的目录
create_directories() {
    print_message "创建必要的目录..."

    mkdir -p data
    mkdir -p logs/nginx
    mkdir -p config

    # 设置权限
    chmod 755 data
    chmod 755 logs

    print_message "目录创建完成"
}

# 生成安全的会话密钥
generate_session_secret() {
    if [ ! -f .env ]; then
        print_message "生成环境配置文件..."

        # 生成32字节的随机密钥
        SESSION_SECRET=$(openssl rand -base64 32)

        cat > .env << EOF
# 运维导航系统环境配置
RACK_ENV=production
SESSION_SECRET=${SESSION_SECRET}
DATABASE_PATH=/app/data/navigation.db
TZ=Asia/Shanghai

# 如果使用Nginx代理，可以修改以下配置
NGINX_PORT=80
NGINX_SSL_PORT=443
EOF

        print_message "环境配置文件已生成: .env"
        print_warning "请根据需要修改 .env 文件中的配置"
    else
        print_message "环境配置文件已存在"
    fi
}

# 构建和启动服务
deploy_simple() {
    print_message "使用简化配置部署..."

    # 停止现有容器
    docker-compose -f docker-compose.simple.yml down 2>/dev/null || true

    # 构建镜像
    print_message "构建 Docker 镜像..."
    docker-compose -f docker-compose.simple.yml build

    # 启动服务
    print_message "启动服务..."
    docker-compose -f docker-compose.simple.yml up -d

    print_message "简化部署完成！"
    print_message "访问地址: http://localhost:4567"
    print_message "管理后台: http://localhost:4567/admin (用户名: admin, 密码: admin123)"
}

# 完整部署（包含Nginx）
deploy_full() {
    print_message "使用完整配置部署（包含 Nginx）..."

    # 停止现有容器
    docker-compose down 2>/dev/null || true

    # 构建镜像
    print_message "构建 Docker 镜像..."
    docker-compose build

    # 启动服务
    print_message "启动服务..."
    docker-compose up -d

    print_message "完整部署完成！"
    print_message "访问地址: http://localhost"
    print_message "管理后台: http://localhost/admin (用户名: admin, 密码: admin123)"
}

# 显示状态
show_status() {
    print_message "服务状态:"
    docker-compose ps 2>/dev/null || docker-compose -f docker-compose.simple.yml ps

    echo ""
    print_message "日志查看命令:"
    echo "  简化版: docker-compose -f docker-compose.simple.yml logs -f"
    echo "  完整版: docker-compose logs -f"
}

# 停止服务
stop_services() {
    print_message "停止服务..."
    docker-compose down 2>/dev/null || true
    docker-compose -f docker-compose.simple.yml down 2>/dev/null || true
    print_message "服务已停止"
}

# 清理
cleanup() {
    print_warning "这将删除所有容器、镜像和数据！"
    read -p "确定要继续吗？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_message "清理中..."
        docker-compose down -v --rmi all 2>/dev/null || true
        docker-compose -f docker-compose.simple.yml down -v --rmi all 2>/dev/null || true
        rm -rf data logs
        print_message "清理完成"
    else
        print_message "取消清理"
    fi
}

# 主菜单
show_menu() {
    echo ""
    echo "请选择操作:"
    echo "1) 简化部署 (仅应用，端口 4567)"
    echo "2) 完整部署 (应用 + Nginx，端口 80)"
    echo "3) 查看状态"
    echo "4) 停止服务"
    echo "5) 清理所有数据"
    echo "6) 退出"
    echo ""
}

# 主函数
main() {
    print_header

    # 检查环境
    check_docker

    # 创建目录
    create_directories

    # 生成配置
    generate_session_secret

    # 显示菜单
    while true; do
        show_menu
        read -p "请输入选项 (1-6): " choice

        case $choice in
            1)
                deploy_simple
                show_status
                ;;
            2)
                deploy_full
                show_status
                ;;
            3)
                show_status
                ;;
            4)
                stop_services
                ;;
            5)
                cleanup
                ;;
            6)
                print_message "再见！"
                exit 0
                ;;
            *)
                print_error "无效选项，请重新选择"
                ;;
        esac

        echo ""
        read -p "按回车键继续..."
    done
}

# 如果直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi