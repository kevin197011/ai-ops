package repository

import (
	"ai-ops/internal/database"
	"ai-ops/internal/models"
	"database/sql"
	"encoding/json"
	"fmt"
)

// HostRepository 主机数据仓库接口
type HostRepository interface {
	Create(host *models.Host) error
	GetByID(id string) (*models.Host, error)
	Update(host *models.Host) error
	Delete(id string) error
	List() ([]*models.Host, error)
	GetStats() (*models.DashboardStats, error)
}

// hostRepository 主机数据仓库实现
type hostRepository struct{}

// NewHostRepository 创建新的主机数据仓库实例
func NewHostRepository() HostRepository {
	return &hostRepository{}
}

// Create 创建主机
func (r *hostRepository) Create(host *models.Host) error {
	tagsJSON, err := json.Marshal(host.Tags)
	if err != nil {
		return fmt.Errorf("序列化标签失败: %v", err)
	}

	query := `
		INSERT INTO hosts (id, name, ip, port, os, cpu, memory, disk, status, description, tags, created_at, updated_at, last_check)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`

	_, err = database.DB.Exec(query,
		host.ID, host.Name, host.IP, host.Port, host.OS, host.CPU, host.Memory, host.Disk,
		host.Status, host.Description, string(tagsJSON), host.CreatedAt, host.UpdatedAt, host.LastCheck)

	if err != nil {
		return fmt.Errorf("创建主机失败: %v", err)
	}

	return nil
}

// GetByID 根据ID获取主机
func (r *hostRepository) GetByID(id string) (*models.Host, error) {
	query := `
		SELECT id, name, ip, port, os, cpu, memory, disk, status, description, tags, created_at, updated_at, last_check
		FROM hosts WHERE id = ?
	`

	row := database.DB.QueryRow(query, id)
	host := &models.Host{}
	var tagsJSON string
	var lastCheck sql.NullTime

	err := row.Scan(
		&host.ID, &host.Name, &host.IP, &host.Port, &host.OS, &host.CPU, &host.Memory, &host.Disk,
		&host.Status, &host.Description, &tagsJSON, &host.CreatedAt, &host.UpdatedAt, &lastCheck)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("主机不存在")
		}
		return nil, fmt.Errorf("查询主机失败: %v", err)
	}

	// 反序列化标签
	if err := json.Unmarshal([]byte(tagsJSON), &host.Tags); err != nil {
		host.Tags = []string{} // 如果反序列化失败，设置为空数组
	}

	// 处理可能为空的last_check字段
	if lastCheck.Valid {
		host.LastCheck = lastCheck.Time
	}

	return host, nil
}

// Update 更新主机
func (r *hostRepository) Update(host *models.Host) error {
	tagsJSON, err := json.Marshal(host.Tags)
	if err != nil {
		return fmt.Errorf("序列化标签失败: %v", err)
	}

	query := `
		UPDATE hosts
		SET name=?, ip=?, port=?, os=?, cpu=?, memory=?, disk=?, status=?, description=?, tags=?, updated_at=?, last_check=?
		WHERE id=?
	`

	result, err := database.DB.Exec(query,
		host.Name, host.IP, host.Port, host.OS, host.CPU, host.Memory, host.Disk,
		host.Status, host.Description, string(tagsJSON), host.UpdatedAt, host.LastCheck, host.ID)

	if err != nil {
		return fmt.Errorf("更新主机失败: %v", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("获取更新行数失败: %v", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("主机不存在")
	}

	return nil
}

// Delete 删除主机
func (r *hostRepository) Delete(id string) error {
	query := "DELETE FROM hosts WHERE id = ?"
	result, err := database.DB.Exec(query, id)
	if err != nil {
		return fmt.Errorf("删除主机失败: %v", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("获取删除行数失败: %v", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("主机不存在")
	}

	return nil
}

// List 获取所有主机列表
func (r *hostRepository) List() ([]*models.Host, error) {
	query := `
		SELECT id, name, ip, port, os, cpu, memory, disk, status, description, tags, created_at, updated_at, last_check
		FROM hosts ORDER BY created_at DESC
	`

	rows, err := database.DB.Query(query)
	if err != nil {
		return nil, fmt.Errorf("查询主机列表失败: %v", err)
	}
	defer rows.Close()

	var hosts []*models.Host
	for rows.Next() {
		host := &models.Host{}
		var tagsJSON string
		var lastCheck sql.NullTime

		err := rows.Scan(
			&host.ID, &host.Name, &host.IP, &host.Port, &host.OS, &host.CPU, &host.Memory, &host.Disk,
			&host.Status, &host.Description, &tagsJSON, &host.CreatedAt, &host.UpdatedAt, &lastCheck)

		if err != nil {
			return nil, fmt.Errorf("扫描主机数据失败: %v", err)
		}

		// 反序列化标签
		if err := json.Unmarshal([]byte(tagsJSON), &host.Tags); err != nil {
			host.Tags = []string{} // 如果反序列化失败，设置为空数组
		}

		// 处理可能为空的last_check字段
		if lastCheck.Valid {
			host.LastCheck = lastCheck.Time
		}

		hosts = append(hosts, host)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("遍历主机数据失败: %v", err)
	}

	return hosts, nil
}

// GetStats 获取仪表盘统计信息
func (r *hostRepository) GetStats() (*models.DashboardStats, error) {
	// 获取主机数量统计
	statsQuery := `
		SELECT
			COUNT(*) as total,
			COUNT(CASE WHEN status = 'online' THEN 1 END) as online,
			COUNT(CASE WHEN status = 'offline' THEN 1 END) as offline
		FROM hosts
	`

	stats := &models.DashboardStats{}
	err := database.DB.QueryRow(statsQuery).Scan(&stats.TotalHosts, &stats.OnlineHosts, &stats.OfflineHosts)
	if err != nil {
		return nil, fmt.Errorf("查询主机统计失败: %v", err)
	}

	// 这里可以扩展为从实际的性能指标表获取数据
	// 目前先使用模拟数据
	if stats.TotalHosts > 0 {
		// 模拟平均资源使用率
		stats.CPUAverage = 45.5
		stats.MemoryAverage = 62.3
		stats.DiskAverage = 38.7

		// 也可以从host_metrics表获取真实数据
		metricsQuery := `
			SELECT
				AVG(cpu_usage) as avg_cpu,
				AVG(memory_usage) as avg_memory,
				AVG(disk_usage) as avg_disk
			FROM host_metrics
			WHERE timestamp > datetime('now', '-1 hour')
		`

		var avgCPU, avgMemory, avgDisk sql.NullFloat64
		err = database.DB.QueryRow(metricsQuery).Scan(&avgCPU, &avgMemory, &avgDisk)
		if err == nil {
			if avgCPU.Valid {
				stats.CPUAverage = avgCPU.Float64
			}
			if avgMemory.Valid {
				stats.MemoryAverage = avgMemory.Float64
			}
			if avgDisk.Valid {
				stats.DiskAverage = avgDisk.Float64
			}
		}
	}

	return stats, nil
}

// SaveMetrics 保存主机性能指标（新增方法）
func (r *hostRepository) SaveMetrics(metrics *models.HostMetrics) error {
	query := `
		INSERT INTO host_metrics (host_id, cpu_usage, memory_usage, disk_usage, network_in, network_out, load_average, timestamp)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)
	`

	_, err := database.DB.Exec(query,
		metrics.HostID, metrics.CPUUsage, metrics.MemoryUsage, metrics.DiskUsage,
		metrics.NetworkIn, metrics.NetworkOut, metrics.LoadAverage, metrics.Timestamp)

	if err != nil {
		return fmt.Errorf("保存性能指标失败: %v", err)
	}

	return nil
}

// GetMetricsByHostID 根据主机ID获取性能指标（新增方法）
func (r *hostRepository) GetMetricsByHostID(hostID string, limit int) ([]*models.HostMetrics, error) {
	query := `
		SELECT host_id, cpu_usage, memory_usage, disk_usage, network_in, network_out, load_average, timestamp
		FROM host_metrics
		WHERE host_id = ?
		ORDER BY timestamp DESC
		LIMIT ?
	`

	rows, err := database.DB.Query(query, hostID, limit)
	if err != nil {
		return nil, fmt.Errorf("查询性能指标失败: %v", err)
	}
	defer rows.Close()

	var metrics []*models.HostMetrics
	for rows.Next() {
		metric := &models.HostMetrics{}
		err := rows.Scan(
			&metric.HostID, &metric.CPUUsage, &metric.MemoryUsage, &metric.DiskUsage,
			&metric.NetworkIn, &metric.NetworkOut, &metric.LoadAverage, &metric.Timestamp)

		if err != nil {
			return nil, fmt.Errorf("扫描性能指标数据失败: %v", err)
		}

		metrics = append(metrics, metric)
	}

	return metrics, nil
}
