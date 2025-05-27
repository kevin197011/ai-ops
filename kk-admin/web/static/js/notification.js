// 通知系统
class NotificationManager {
    constructor() {
        this.container = null;
        this.init();
    }

    init() {
        // 等待DOM加载完成后初始化
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.createContainer());
        } else {
            this.createContainer();
        }
    }

    createContainer() {
        // 创建通知容器
        this.container = document.createElement('div');
        this.container.id = 'notification-container';
        this.container.className = 'fixed top-4 left-1/2 transform -translate-x-1/2 z-50 flex flex-row items-start space-x-3 max-w-screen-xl overflow-x-auto';
        document.body.appendChild(this.container);
    }

    show(message, type = 'info', duration = 5000) {
        const notification = this.createNotification(message, type);
        this.container.appendChild(notification);

        // 入场动画
        setTimeout(() => {
            notification.classList.remove('scale-0', 'opacity-0');
        }, 100);

        // 自动移除
        if (duration > 0) {
            setTimeout(() => {
                this.remove(notification);
            }, duration);
        }

        return notification;
    }

    createNotification(message, type) {
        const notification = document.createElement('div');
        notification.className = `
            transform scale-0 opacity-0 transition-all duration-300 ease-in-out
            w-80 bg-white shadow-xl rounded-lg pointer-events-auto border border-gray-200 overflow-hidden flex-shrink-0
        `;

        const config = this.getTypeConfig(type);

        notification.innerHTML = `
            <div class="p-4">
                <div class="flex items-start">
                    <div class="flex-shrink-0">
                        <div class="w-8 h-8 rounded-full flex items-center justify-center ${config.bgColor}">
                            <i class="${config.icon} text-white text-sm"></i>
                        </div>
                    </div>
                    <div class="ml-3 flex-1">
                        <p class="text-sm font-semibold text-gray-900">${config.title}</p>
                        <p class="mt-1 text-xs text-gray-600">${message}</p>
                    </div>
                    <div class="ml-2 flex-shrink-0">
                        <button class="bg-white rounded-full p-1 inline-flex text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none transition-colors duration-200" onclick="notification.remove(this.closest('.transform'))">
                            <span class="sr-only">关闭</span>
                            <i class="fas fa-times text-xs"></i>
                        </button>
                    </div>
                </div>
            </div>
            <div class="h-1 ${config.progressColor}">
                <div class="h-full bg-current transition-all duration-5000 ease-linear animate-progress"></div>
            </div>
        `;

        return notification;
    }

    getTypeConfig(type) {
        const configs = {
            success: {
                title: '操作成功',
                icon: 'fas fa-check',
                bgColor: 'bg-green-500',
                progressColor: 'text-green-500'
            },
            error: {
                title: '操作失败',
                icon: 'fas fa-times',
                bgColor: 'bg-red-500',
                progressColor: 'text-red-500'
            },
            warning: {
                title: '警告',
                icon: 'fas fa-exclamation-triangle',
                bgColor: 'bg-yellow-500',
                progressColor: 'text-yellow-500'
            },
            info: {
                title: '提示',
                icon: 'fas fa-info',
                bgColor: 'bg-blue-500',
                progressColor: 'text-blue-500'
            }
        };
        return configs[type] || configs.info;
    }

    remove(notification) {
        notification.classList.add('scale-0', 'opacity-0');
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }

    // 便捷方法
    success(message, duration = 4000) {
        return this.show(message, 'success', duration);
    }

    error(message, duration = 6000) {
        return this.show(message, 'error', duration);
    }

    warning(message, duration = 5000) {
        return this.show(message, 'warning', duration);
    }

    info(message, duration = 4000) {
        return this.show(message, 'info', duration);
    }
}

// 确认对话框
class ConfirmDialog {
    static show(title, message, confirmText = '确认', cancelText = '取消') {
        return new Promise((resolve) => {
            const dialog = document.createElement('div');
            dialog.className = 'fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50';
            dialog.innerHTML = `
                <div class="flex items-center justify-center min-h-screen px-4">
                    <div class="bg-white rounded-lg shadow-xl max-w-md w-full transform transition-all">
                        <div class="p-6">
                            <div class="flex items-center justify-center mb-4">
                                <div class="w-12 h-12 rounded-full bg-red-100 flex items-center justify-center">
                                    <i class="fas fa-exclamation-triangle text-red-600 text-xl"></i>
                                </div>
                            </div>
                            <div class="text-center">
                                <h3 class="text-xl font-semibold text-gray-900 mb-2">${title}</h3>
                                <p class="text-gray-600 mb-6">${message}</p>
                            </div>
                            <div class="flex justify-center space-x-3">
                                <button id="cancel-btn" class="px-6 py-2 text-sm font-medium text-gray-700 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition-colors duration-200">
                                    ${cancelText}
                                </button>
                                <button id="confirm-btn" class="px-6 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-md hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-colors duration-200">
                                    ${confirmText}
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            `;

            document.body.appendChild(dialog);

            // 绑定事件
            dialog.querySelector('#confirm-btn').onclick = () => {
                document.body.removeChild(dialog);
                resolve(true);
            };

            dialog.querySelector('#cancel-btn').onclick = () => {
                document.body.removeChild(dialog);
                resolve(false);
            };

            // 点击背景关闭
            dialog.onclick = (e) => {
                if (e.target === dialog) {
                    document.body.removeChild(dialog);
                    resolve(false);
                }
            };
        });
    }
}

// 加载提示管理器
class LoadingManager {
    constructor() {
        this.overlay = null;
    }

    show(message = '加载中...') {
        if (this.overlay) {
            this.hide();
        }

        this.overlay = document.createElement('div');
        this.overlay.className = 'fixed inset-0 bg-gray-600 bg-opacity-50 z-50 flex items-center justify-center';
        this.overlay.innerHTML = `
            <div class="bg-white rounded-lg p-8 shadow-xl border border-gray-200 min-w-80">
                <div class="flex flex-col items-center text-center">
                    <div class="animate-spin rounded-full h-8 w-8 border-3 border-blue-500 border-t-transparent mb-4"></div>
                    <span class="text-gray-700 font-medium text-lg">${message}</span>
                </div>
            </div>
        `;

        document.body.appendChild(this.overlay);
    }

    hide() {
        if (this.overlay && this.overlay.parentNode) {
            this.overlay.parentNode.removeChild(this.overlay);
            this.overlay = null;
        }
    }
}

// 全局实例
const notification = new NotificationManager();
const loading = new LoadingManager();

// 添加进度条动画样式和自定义边框
const style = document.createElement('style');
style.textContent = `
    @keyframes progress {
        from { width: 100%; }
        to { width: 0%; }
    }
    .animate-progress {
        animation: progress var(--duration, 5s) linear forwards;
    }
    .duration-5000 {
        --duration: 5s;
    }
    .border-3 {
        border-width: 3px;
    }
    .w-80 {
        width: 20rem;
    }
    .min-w-80 {
        min-width: 20rem;
    }
    .flex-shrink-0 {
        flex-shrink: 0;
    }
`;
document.head.appendChild(style);