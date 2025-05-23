package services

import (
	"ai-ops/internal/models"
	"ai-ops/internal/repository"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"net"
	"time"
)

// HostService 主机服务接口
type HostService interface {
	CreateHost(host *models.Host) error
	GetHost(id string) (*models.Host, error)
	UpdateHost(id string, host *models.Host) error
	DeleteHost(id string) error
	ListHosts() ([]*models.Host, error)
	CheckHost(id string) error
	GetDashboardStats() (*models.DashboardStats, error)
}

// hostService 主机服务实现
type hostService struct {
	repo repository.HostRepository
}

// NewHostService 创建新的主机服务实例
func NewHostService(repo repository.HostRepository) HostService {
	return &hostService{
		repo: repo,
	}
}

// generateID 生成随机ID
func (s *hostService) generateID() string {
	bytes := make([]byte, 8)
	rand.Read(bytes)
	return hex.EncodeToString(bytes)
}

// CreateHost 创建主机
func (s *hostService) CreateHost(host *models.Host) error {
	host.ID = s.generateID()
	host.CreatedAt = time.Now()
	host.UpdatedAt = time.Now()
	host.Status = models.HostStatusUnknown

	// 设置默认端口
	if host.Port == 0 {
		host.Port = 22
	}

	return s.repo.Create(host)
}

// GetHost 获取主机信息
func (s *hostService) GetHost(id string) (*models.Host, error) {
	return s.repo.GetByID(id)
}

// UpdateHost 更新主机信息
func (s *hostService) UpdateHost(id string, updatedHost *models.Host) error {
	// 获取现有主机信息
	existingHost, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}

	// 保留原有的创建时间和ID
	updatedHost.ID = existingHost.ID
	updatedHost.CreatedAt = existingHost.CreatedAt
	updatedHost.UpdatedAt = time.Now()

	return s.repo.Update(updatedHost)
}

// DeleteHost 删除主机
func (s *hostService) DeleteHost(id string) error {
	return s.repo.Delete(id)
}

// ListHosts 获取主机列表
func (s *hostService) ListHosts() ([]*models.Host, error) {
	return s.repo.List()
}

// CheckHost 检查主机连通性
func (s *hostService) CheckHost(id string) error {
	host, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}

	// 简单的TCP连接测试
	address := fmt.Sprintf("%s:%d", host.IP, host.Port)
	conn, err := net.DialTimeout("tcp", address, 5*time.Second)
	if err != nil {
		host.Status = models.HostStatusOffline
	} else {
		host.Status = models.HostStatusOnline
		conn.Close()
	}

	host.LastCheck = time.Now()
	host.UpdatedAt = time.Now()

	return s.repo.Update(host)
}

// GetDashboardStats 获取仪表盘统计信息
func (s *hostService) GetDashboardStats() (*models.DashboardStats, error) {
	return s.repo.GetStats()
}
