require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require 'json'

# Configuration
configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] || 'a_very_long_random_string_that_is_at_least_32_bytes_long_for_session_security'
  set :public_folder, 'public'
  set :views, 'views'

  # Ensure sessions work with AJAX requests
  use Rack::Session::Cookie,
    :key => 'rack.session',
    :path => '/',
    :expire_after => 2592000, # 30 days
    :secret => ENV['SESSION_SECRET'] || 'a_very_long_random_string_that_is_at_least_32_bytes_long_for_session_security',
    :httponly => true,
    :same_site => :lax
end

# Database setup
def get_db_path
  ENV['DATABASE_PATH'] || 'navigation.db'
end

def init_db
  db_path = get_db_path

  # 确保数据目录存在
  db_dir = File.dirname(db_path)
  Dir.mkdir(db_dir) unless Dir.exist?(db_dir)

  db = SQLite3::Database.new db_path

  # Create categories table
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      sort_order INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  SQL

  # Create navigation links table
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS nav_links (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      url TEXT NOT NULL,
      description TEXT,
      category_id INTEGER,
      icon TEXT,
      sort_order INTEGER DEFAULT 0,
      is_active BOOLEAN DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (category_id) REFERENCES categories (id)
    );
  SQL

  # Create admin users table
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS admin_users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  SQL

  # Create default admin user (username: admin, password: admin123)
  password_hash = BCrypt::Password.create('admin123')
  db.execute "INSERT OR IGNORE INTO admin_users (username, password_hash) VALUES (?, ?)",
             ['admin', password_hash]

  # Insert sample data if tables are empty
  category_count = db.execute("SELECT COUNT(*) FROM categories")[0][0]
  if category_count == 0
    # Sample categories
    db.execute "INSERT INTO categories (name, description, sort_order) VALUES (?, ?, ?)",
               ['监控系统', '各种监控和告警系统', 1]
    db.execute "INSERT INTO categories (name, description, sort_order) VALUES (?, ?, ?)",
               ['日志系统', '日志收集和分析系统', 2]
    db.execute "INSERT INTO categories (name, description, sort_order) VALUES (?, ?, ?)",
               ['容器管理', 'Docker和Kubernetes管理', 3]
    db.execute "INSERT INTO categories (name, description, sort_order) VALUES (?, ?, ?)",
               ['CI/CD', '持续集成和部署工具', 4]

    # Sample navigation links
    db.execute "INSERT INTO nav_links (title, url, description, category_id, icon, sort_order) VALUES (?, ?, ?, ?, ?, ?)",
               ['Prometheus', 'http://prometheus.example.com', '监控数据收集和存储', 1, '📊', 1]
    db.execute "INSERT INTO nav_links (title, url, description, category_id, icon, sort_order) VALUES (?, ?, ?, ?, ?, ?)",
               ['Grafana', 'http://grafana.example.com', '数据可视化仪表板', 1, '📈', 2]
    db.execute "INSERT INTO nav_links (title, url, description, category_id, icon, sort_order) VALUES (?, ?, ?, ?, ?, ?)",
               ['ELK Stack', 'http://elasticsearch.example.com', '日志搜索和分析', 2, '🔍', 1]
    db.execute "INSERT INTO nav_links (title, url, description, category_id, icon, sort_order) VALUES (?, ?, ?, ?, ?, ?)",
               ['Docker Registry', 'http://registry.example.com', '容器镜像仓库', 3, '🐳', 1]
    db.execute "INSERT INTO nav_links (title, url, description, category_id, icon, sort_order) VALUES (?, ?, ?, ?, ?, ?)",
               ['Jenkins', 'http://jenkins.example.com', '自动化构建和部署', 4, '🔧', 1]
  end

  db.close
end

# Helper methods
def get_db
  SQLite3::Database.new get_db_path
end

def require_admin
  redirect '/admin/login' unless session[:admin_logged_in]
end

def build_pagination_url(page, per_page = nil, category = nil)
  # 使用当前参数作为默认值
  per_page ||= params[:per_page] || 10
  category ||= params[:category]

  url = "/admin/links?page=#{page}&per_page=#{per_page}"
  url += "&category=#{category}" if category && !category.empty?
  url
end

# 获取当前请求的基础URL，自动适配端口
def get_base_url
  scheme = request.scheme
  host = request.host
  port = request.port

  # 如果是标准端口，不显示端口号
  if (scheme == 'http' && port == 80) || (scheme == 'https' && port == 443)
    "#{scheme}://#{host}"
  else
    "#{scheme}://#{host}:#{port}"
  end
end

def get_categories_with_links
  db = get_db
  categories = db.execute("SELECT * FROM categories ORDER BY sort_order, name")
  result = categories.map do |category|
    links = db.execute("SELECT * FROM nav_links WHERE category_id = ? AND is_active = 1 ORDER BY sort_order, title", [category[0]])
    {
      id: category[0],
      name: category[1],
      description: category[2],
      sort_order: category[3],
      links: links.map { |link| {
        id: link[0],
        title: link[1],
        url: link[2],
        description: link[3],
        icon: link[5],
        sort_order: link[6]
      }}
    }
  end
  db.close
  result
end

# Initialize database
init_db

# Routes
get '/' do
  @categories = get_categories_with_links
  @base_url = get_base_url
  erb :index
end

# Test route to check base URL
get '/test-url' do
  content_type :json
  {
    base_url: get_base_url,
    scheme: request.scheme,
    host: request.host,
    port: request.port,
    request_url: request.url
  }.to_json
end

# Admin routes
get '/admin' do
  require_admin
  redirect '/admin/dashboard'
end

get '/admin/login' do
  @base_url = get_base_url
  erb :admin_login, layout: :admin_layout
end

post '/admin/login' do
  username = params[:username]
  password = params[:password]

  db = get_db
  user = db.execute("SELECT * FROM admin_users WHERE username = ?", [username]).first
  db.close

  if user && BCrypt::Password.new(user[2]) == password
    session[:admin_logged_in] = true
    session[:admin_username] = username
    redirect '/admin/dashboard'
  else
    @error = '用户名或密码错误'
    @base_url = get_base_url
    erb :admin_login, layout: :admin_layout
  end
end

get '/admin/logout' do
  session.clear
  redirect '/admin/login'
end

get '/admin/dashboard' do
  require_admin
  @categories = get_categories_with_links
  @base_url = get_base_url
  erb :admin_dashboard, layout: :admin_layout
end

# Password change
get '/admin/change-password' do
  require_admin
  @base_url = get_base_url
  erb :admin_change_password, layout: :admin_layout
end

post '/admin/change-password' do
  require_admin

  current_password = params[:current_password]
  new_password = params[:new_password]
  confirm_password = params[:confirm_password]

  # Validate input
  if current_password.nil? || current_password.empty?
    @error = '请输入当前密码'
    @base_url = get_base_url
    return erb :admin_change_password, layout: :admin_layout
  end

  if new_password.nil? || new_password.empty?
    @error = '请输入新密码'
    @base_url = get_base_url
    return erb :admin_change_password, layout: :admin_layout
  end

  if new_password.length < 6
    @error = '新密码长度至少6位'
    @base_url = get_base_url
    return erb :admin_change_password, layout: :admin_layout
  end

  if new_password != confirm_password
    @error = '两次输入的新密码不一致'
    @base_url = get_base_url
    return erb :admin_change_password, layout: :admin_layout
  end

  # Verify current password
  db = get_db
  user = db.execute("SELECT * FROM admin_users WHERE username = ?", [session[:admin_username]]).first

  if user.nil? || !BCrypt::Password.new(user[2]).is_password?(current_password)
    @error = '当前密码错误'
    @base_url = get_base_url
    db.close
    return erb :admin_change_password, layout: :admin_layout
  end

  # Update password
  new_password_hash = BCrypt::Password.create(new_password)
  db.execute("UPDATE admin_users SET password_hash = ? WHERE username = ?",
             [new_password_hash, session[:admin_username]])
  db.close

  @success = '密码修改成功！'
  @base_url = get_base_url
  erb :admin_change_password, layout: :admin_layout
end

# Category management
get '/admin/categories' do
  require_admin
  db = get_db
  @categories = db.execute("SELECT * FROM categories ORDER BY sort_order, name")
  @base_url = get_base_url
  db.close
  erb :admin_categories, layout: :admin_layout
end

post '/admin/categories' do
  require_admin

  # Handle both JSON and form data
  if request.content_type&.include?('application/json')
    request.body.rewind
    data = JSON.parse(request.body.read)
    name = data['name']
    description = data['description']
    sort_order = data['sort_order'].to_i

    begin
      db = get_db
      db.execute("INSERT INTO categories (name, description, sort_order) VALUES (?, ?, ?)",
                 [name, description, sort_order])
      db.close

      content_type :json
      { success: true }.to_json
    rescue => e
      content_type :json
      { success: false, error: e.message }.to_json
    end
  else
    # Traditional form submission
    name = params[:name]
    description = params[:description]
    sort_order = params[:sort_order].to_i

    db = get_db
    db.execute("INSERT INTO categories (name, description, sort_order) VALUES (?, ?, ?)",
               [name, description, sort_order])
    db.close

    redirect '/admin/categories'
  end
end

delete '/admin/categories/:id' do
  require_admin
  db = get_db
  db.execute("DELETE FROM categories WHERE id = ?", [params[:id]])
  db.execute("DELETE FROM nav_links WHERE category_id = ?", [params[:id]])
  db.close

  content_type :json
  { success: true }.to_json
end

# Update category
put '/admin/categories/:id' do
  require_admin
  content_type :json

  begin
    request.body.rewind
    data = JSON.parse(request.body.read)

    name = data['name']
    description = data['description']
    sort_order = data['sort_order'].to_i

    db = get_db
    db.execute("UPDATE categories SET name = ?, description = ?, sort_order = ? WHERE id = ?",
               [name, description, sort_order, params[:id]])
    db.close

    { success: true }.to_json
  rescue => e
    { success: false, error: e.message }.to_json
  end
end

# Navigation links management
get '/admin/links' do
  require_admin

  # 获取分页参数
  page = (params[:page] || 1).to_i
  per_page = (params[:per_page] || 10).to_i
  category_filter = params[:category]

  # 确保页码有效
  page = 1 if page < 1
  per_page = 10 if per_page < 1 || per_page > 100

  db = get_db

  # 构建查询条件
  where_clause = ""
  query_params = []

  if category_filter && !category_filter.empty?
    where_clause = "WHERE c.name = ?"
    query_params << category_filter
  end

  # 获取总数
  count_sql = <<-SQL
    SELECT COUNT(*)
    FROM nav_links nl
    LEFT JOIN categories c ON nl.category_id = c.id
    #{where_clause}
  SQL
  total_count = db.execute(count_sql, query_params)[0][0]

  # 计算分页信息
  total_pages = (total_count.to_f / per_page).ceil
  total_pages = 1 if total_pages < 1
  page = total_pages if page > total_pages

  offset = (page - 1) * per_page

  # 获取当前页数据
  links_sql = <<-SQL
    SELECT nl.*, c.name as category_name
    FROM nav_links nl
    LEFT JOIN categories c ON nl.category_id = c.id
    #{where_clause}
    ORDER BY nl.sort_order, nl.title
    LIMIT ? OFFSET ?
  SQL
  @links = db.execute(links_sql, query_params + [per_page, offset])

  # 获取所有分类（用于过滤器）
  @categories = db.execute("SELECT * FROM categories ORDER BY name")

  # 分页信息
  @pagination = {
    current_page: page,
    per_page: per_page,
    total_count: total_count,
    total_pages: total_pages,
    has_prev: page > 1,
    has_next: page < total_pages,
    prev_page: page > 1 ? page - 1 : nil,
    next_page: page < total_pages ? page + 1 : nil,
    category_filter: category_filter
  }

  @base_url = get_base_url
  db.close
  erb :admin_links, layout: :admin_layout
end

post '/admin/links' do
  require_admin

  # Handle both JSON and form data
  if request.content_type&.include?('application/json')
    request.body.rewind
    data = JSON.parse(request.body.read)
    title = data['title']
    url = data['url']
    description = data['description']
    category_id = data['category_id'].to_i
    icon = data['icon']
    sort_order = data['sort_order'].to_i

    begin
      db = get_db
      db.execute("INSERT INTO nav_links (title, url, description, category_id, icon, sort_order, is_active) VALUES (?, ?, ?, ?, ?, ?, 1)",
                 [title, url, description, category_id, icon, sort_order])
      db.close

      content_type :json
      { success: true }.to_json
    rescue => e
      content_type :json
      { success: false, error: e.message }.to_json
    end
  else
    # Traditional form submission
    title = params[:title]
    url = params[:url]
    description = params[:description]
    category_id = params[:category_id].to_i
    icon = params[:icon]
    sort_order = params[:sort_order].to_i

    db = get_db
    db.execute("INSERT INTO nav_links (title, url, description, category_id, icon, sort_order, is_active) VALUES (?, ?, ?, ?, ?, ?, 1)",
               [title, url, description, category_id, icon, sort_order])
    db.close

    redirect '/admin/links'
  end
end

delete '/admin/links/:id' do
  require_admin
  db = get_db
  db.execute("DELETE FROM nav_links WHERE id = ?", [params[:id]])
  db.close

  content_type :json
  { success: true }.to_json
end

# Update link
put '/admin/links/:id' do
  require_admin
  content_type :json

  begin
    request.body.rewind
    data = JSON.parse(request.body.read)

    title = data['title']
    url = data['url']
    description = data['description']
    category_id = data['category_id']
    icon = data['icon']
    sort_order = data['sort_order'].to_i

    db = get_db
    db.execute("UPDATE nav_links SET title = ?, url = ?, description = ?, category_id = ?, icon = ?, sort_order = ? WHERE id = ?",
               [title, url, description, category_id, icon, sort_order, params[:id]])
    db.close

    { success: true }.to_json
  rescue => e
    { success: false, error: e.message }.to_json
  end
end

put '/admin/links/:id/toggle' do
  require_admin
  db = get_db
  current_status = db.execute("SELECT is_active FROM nav_links WHERE id = ?", [params[:id]])[0][0]
  new_status = current_status == 1 ? 0 : 1
  db.execute("UPDATE nav_links SET is_active = ? WHERE id = ?", [new_status, params[:id]])
  db.close

  content_type :json
  { success: true, is_active: new_status }.to_json
end

# Search suggestions API
get '/api/search/suggestions' do
  content_type :json

  query = params[:q]
  limit = (params[:limit] || 10).to_i

  # 如果查询为空或太短，返回空结果
  if query.nil? || query.strip.length < 1
    return { suggestions: [] }.to_json
  end

  query = query.strip.downcase

  db = get_db

  # 搜索链接标题、描述和分类名称
  search_sql = <<-SQL
    SELECT DISTINCT
      nl.title,
      nl.description,
      c.name as category_name,
      nl.url,
      nl.icon,
      'link' as type,
      CASE
        WHEN LOWER(nl.title) LIKE ? THEN 1
        ELSE 3
      END as priority
    FROM nav_links nl
    LEFT JOIN categories c ON nl.category_id = c.id
    WHERE nl.is_active = 1
      AND (
        LOWER(nl.title) LIKE ? OR
        LOWER(nl.description) LIKE ? OR
        LOWER(c.name) LIKE ?
      )

    UNION

    SELECT DISTINCT
      c.name as title,
      c.description,
      c.name as category_name,
      '' as url,
      '📁' as icon,
      'category' as type,
      CASE
        WHEN LOWER(c.name) LIKE ? THEN 2
        ELSE 4
      END as priority
    FROM categories c
    WHERE EXISTS (
      SELECT 1 FROM nav_links nl
      WHERE nl.category_id = c.id AND nl.is_active = 1
    )
    AND LOWER(c.name) LIKE ?

    ORDER BY priority, title
    LIMIT ?
  SQL

  like_query = "%#{query}%"
  starts_with_query = "#{query}%"

  results = db.execute(search_sql, [
    starts_with_query,                   # 第一个SELECT的优先级判断
    like_query, like_query, like_query,  # 第一个SELECT的WHERE条件
    starts_with_query,                   # 第二个SELECT的优先级判断
    like_query,                          # 第二个SELECT的WHERE条件
    limit
  ])

  suggestions = results.map do |row|
    {
      title: row[0],
      description: row[1] || '',
      category: row[2] || '',
      url: row[3] || '',
      icon: row[4] || '🔗',
      type: row[5]
    }
  end

  db.close

  { suggestions: suggestions }.to_json
end
