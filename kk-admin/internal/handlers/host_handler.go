package handlers

import (
	"ai-ops/internal/models"
	"ai-ops/internal/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

// HostHandler 主机处理器
type HostHandler struct {
	hostService services.HostService
}

// NewHostHandler 创建新的主机处理器
func NewHostHandler(hostService services.HostService) *HostHandler {
	return &HostHandler{
		hostService: hostService,
	}
}

// ListHosts 获取主机列表
func (h *HostHandler) ListHosts(c *gin.Context) {
	hosts, err := h.hostService.ListHosts()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": hosts,
	})
}

// CreateHost 创建主机
func (h *HostHandler) CreateHost(c *gin.Context) {
	var host models.Host
	if err := c.ShouldBindJSON(&host); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的请求数据: " + err.Error(),
		})
		return
	}

	if err := h.hostService.CreateHost(&host); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "主机创建成功",
		"data":    host,
	})
}

// GetHost 获取单个主机信息
func (h *HostHandler) GetHost(c *gin.Context) {
	id := c.Param("id")
	host, err := h.hostService.GetHost(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": host,
	})
}

// UpdateHost 更新主机信息
func (h *HostHandler) UpdateHost(c *gin.Context) {
	id := c.Param("id")
	var host models.Host
	if err := c.ShouldBindJSON(&host); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "无效的请求数据: " + err.Error(),
		})
		return
	}

	if err := h.hostService.UpdateHost(id, &host); err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "主机更新成功",
		"data":    host,
	})
}

// DeleteHost 删除主机
func (h *HostHandler) DeleteHost(c *gin.Context) {
	id := c.Param("id")
	if err := h.hostService.DeleteHost(id); err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "主机删除成功",
	})
}

// CheckHost 检查主机连通性
func (h *HostHandler) CheckHost(c *gin.Context) {
	id := c.Param("id")
	if err := h.hostService.CheckHost(id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
		return
	}

	// 获取更新后的主机状态
	host, err := h.hostService.GetHost(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "主机检查完成",
		"data":    host,
	})
}

// GetDashboardStats 获取仪表盘统计信息
func (h *HostHandler) GetDashboardStats(c *gin.Context) {
	stats, err := h.hostService.GetDashboardStats()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": stats,
	})
}
