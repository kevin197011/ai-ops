package models

import "time"

// HostStatus 主机状态枚举
type HostStatus string

const (
	HostStatusOnline  HostStatus = "online"
	HostStatusOffline HostStatus = "offline"
	HostStatusUnknown HostStatus = "unknown"
)

// Host 主机信息结构体
type Host struct {
	ID          string     `json:"id"`
	Name        string     `json:"name" binding:"required"`
	IP          string     `json:"ip" binding:"required"`
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

// HostMetrics 主机性能指标
type HostMetrics struct {
	HostID      string    `json:"host_id"`
	CPUUsage    float64   `json:"cpu_usage"`
	MemoryUsage float64   `json:"memory_usage"`
	DiskUsage   float64   `json:"disk_usage"`
	NetworkIn   float64   `json:"network_in"`
	NetworkOut  float64   `json:"network_out"`
	LoadAverage float64   `json:"load_average"`
	Timestamp   time.Time `json:"timestamp"`
}

// DashboardStats 仪表盘统计信息
type DashboardStats struct {
	TotalHosts    int     `json:"total_hosts"`
	OnlineHosts   int     `json:"online_hosts"`
	OfflineHosts  int     `json:"offline_hosts"`
	CPUAverage    float64 `json:"cpu_average"`
	MemoryAverage float64 `json:"memory_average"`
	DiskAverage   float64 `json:"disk_average"`
}
