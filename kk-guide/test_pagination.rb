#!/usr/bin/env ruby

require 'sqlite3'
require 'net/http'
require 'uri'
require 'json'

# 数据库连接
db = SQLite3::Database.new 'navigation.db'

puts "正在添加测试数据..."

# 添加更多分类（如果不存在）
categories = [
  ['API网关', 'API管理和网关服务'],
  ['数据库管理', '数据库监控和管理工具'],
  ['安全工具', '安全扫描和防护工具'],
  ['开发工具', '开发和调试工具'],
  ['文档系统', '文档管理和知识库']
]

categories.each do |name, desc|
  begin
    db.execute("INSERT INTO categories (name, description, sort_order) VALUES (?, ?, ?)",
               [name, desc, rand(1..10)])
  rescue SQLite3::ConstraintException
    # 分类已存在，跳过
  end
end

# 获取所有分类
all_categories = db.execute("SELECT id FROM categories")

# 添加测试链接
test_links = [
  ['Kong Gateway', 'https://kong.example.com', 'API网关管理平台'],
  ['Nginx Manager', 'https://nginx.example.com', 'Nginx管理工具'],
  ['MySQL Monitor', 'https://mysql.example.com', 'MySQL监控工具'],
  ['Redis Commander', 'https://redis.example.com', 'Redis管理界面'],
  ['Vault UI', 'https://vault.example.com', 'HashiCorp Vault管理'],
  ['Consul UI', 'https://consul.example.com', '服务发现和配置'],
  ['Jaeger Tracing', 'https://jaeger.example.com', '分布式链路追踪'],
  ['Zipkin', 'https://zipkin.example.com', '分布式追踪系统'],
  ['SonarQube', 'https://sonar.example.com', '代码质量检查'],
  ['GitLab', 'https://gitlab.example.com', '代码仓库和CI/CD'],
  ['Harbor Registry', 'https://harbor.example.com', '企业级容器镜像仓库'],
  ['Rancher', 'https://rancher.example.com', 'Kubernetes管理平台'],
  ['Portainer', 'https://portainer.example.com', 'Docker容器管理'],
  ['Nexus Repository', 'https://nexus.example.com', '制品仓库管理'],
  ['Artifactory', 'https://artifactory.example.com', 'JFrog制品仓库'],
  ['ElasticSearch', 'https://es.example.com', '搜索和分析引擎'],
  ['Kibana Dashboard', 'https://kibana.example.com', '数据可视化工具'],
  ['Logstash', 'https://logstash.example.com', '日志收集处理'],
  ['Fluentd', 'https://fluentd.example.com', '统一日志收集'],
  ['Kafka Manager', 'https://kafka.example.com', '消息队列管理'],
  ['RabbitMQ', 'https://rabbitmq.example.com', '消息队列服务'],
  ['MinIO Console', 'https://minio.example.com', '对象存储管理'],
  ['Ceph Dashboard', 'https://ceph.example.com', '分布式存储管理'],
  ['Zabbix Server', 'https://zabbix.example.com', '网络监控系统'],
  ['Nagios Core', 'https://nagios.example.com', '主机和服务监控'],
  ['PRTG Monitor', 'https://prtg.example.com', '网络监控工具'],
  ['Datadog', 'https://datadog.example.com', '云监控和分析'],
  ['New Relic', 'https://newrelic.example.com', '应用性能监控'],
  ['AppDynamics', 'https://appdynamics.example.com', '应用监控平台'],
  ['Splunk Enterprise', 'https://splunk.example.com', '大数据分析平台']
]

# 图标列表
icons = ['🔧', '⚙️', '📊', '📈', '🔍', '🛡️', '🌐', '📦', '🚀', '⚡', '🔗', '💻', '📡', '🎯', '🐳']

test_links.each_with_index do |link_data, index|
  title, url, description = link_data
  category_id = all_categories.sample[0] # 随机选择分类
  icon = icons.sample
  sort_order = index + 1

  begin
    db.execute("INSERT INTO nav_links (title, url, description, category_id, icon, sort_order, is_active) VALUES (?, ?, ?, ?, ?, ?, 1)",
               [title, url, description, category_id, icon, sort_order])
  rescue SQLite3::ConstraintException
    # 链接已存在，跳过
  end
end

# 获取总链接数
total_links = db.execute("SELECT COUNT(*) FROM nav_links")[0][0]
puts "数据库中共有 #{total_links} 个链接"

db.close

puts "测试数据添加完成！"
puts ""
puts "现在可以测试分页功能："
puts "1. 访问: http://localhost:4567/admin/login"
puts "2. 使用默认账户登录: admin / admin123"
puts "3. 进入链接管理页面测试分页功能"
puts ""
puts "测试分页URL示例："
puts "- 第1页，每页5条: http://localhost:4567/admin/links?page=1&per_page=5"
puts "- 第2页，每页10条: http://localhost:4567/admin/links?page=2&per_page=10"
puts "- 筛选分类: http://localhost:4567/admin/links?page=1&per_page=10&category=监控系统"
