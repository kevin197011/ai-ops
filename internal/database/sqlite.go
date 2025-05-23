package database

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"

	_ "github.com/mattn/go-sqlite3"
)

// DB 全局数据库连接
var DB *sql.DB

// InitDatabase 初始化数据库
func InitDatabase(dbPath string) error {
	// 确保数据库目录存在
	dir := filepath.Dir(dbPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("创建数据库目录失败: %v", err)
	}

	// 打开数据库连接
	db, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		return fmt.Errorf("打开数据库失败: %v", err)
	}

	// 测试连接
	if err := db.Ping(); err != nil {
		return fmt.Errorf("数据库连接测试失败: %v", err)
	}

	DB = db

	// 创建表结构
	if err := createTables(); err != nil {
		return fmt.Errorf("创建数据库表失败: %v", err)
	}

	return nil
}

// createTables 创建数据库表
func createTables() error {
	// 主机表
	hostTableSQL := `
	CREATE TABLE IF NOT EXISTS hosts (
		id TEXT PRIMARY KEY,
		name TEXT NOT NULL,
		ip TEXT NOT NULL,
		port INTEGER NOT NULL DEFAULT 22,
		os TEXT,
		cpu TEXT,
		memory TEXT,
		disk TEXT,
		status TEXT NOT NULL DEFAULT 'unknown',
		description TEXT,
		tags TEXT, -- JSON格式存储标签数组
		created_at DATETIME NOT NULL,
		updated_at DATETIME NOT NULL,
		last_check DATETIME
	);`

	if _, err := DB.Exec(hostTableSQL); err != nil {
		return fmt.Errorf("创建hosts表失败: %v", err)
	}

	// 主机性能指标表
	metricsTableSQL := `
	CREATE TABLE IF NOT EXISTS host_metrics (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		host_id TEXT NOT NULL,
		cpu_usage REAL NOT NULL DEFAULT 0,
		memory_usage REAL NOT NULL DEFAULT 0,
		disk_usage REAL NOT NULL DEFAULT 0,
		network_in REAL NOT NULL DEFAULT 0,
		network_out REAL NOT NULL DEFAULT 0,
		load_average REAL NOT NULL DEFAULT 0,
		timestamp DATETIME NOT NULL,
		FOREIGN KEY (host_id) REFERENCES hosts(id) ON DELETE CASCADE
	);`

	if _, err := DB.Exec(metricsTableSQL); err != nil {
		return fmt.Errorf("创建host_metrics表失败: %v", err)
	}

	// 创建索引
	indexSQL := []string{
		"CREATE INDEX IF NOT EXISTS idx_hosts_ip ON hosts(ip);",
		"CREATE INDEX IF NOT EXISTS idx_hosts_status ON hosts(status);",
		"CREATE INDEX IF NOT EXISTS idx_metrics_host_id ON host_metrics(host_id);",
		"CREATE INDEX IF NOT EXISTS idx_metrics_timestamp ON host_metrics(timestamp);",
	}

	for _, sql := range indexSQL {
		if _, err := DB.Exec(sql); err != nil {
			return fmt.Errorf("创建索引失败: %v", err)
		}
	}

	return nil
}

// CloseDatabase 关闭数据库连接
func CloseDatabase() error {
	if DB != nil {
		return DB.Close()
	}
	return nil
}
