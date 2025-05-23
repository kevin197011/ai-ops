package main

import (
	"ai-ops/internal/database"
	"ai-ops/internal/handlers"
	"ai-ops/internal/middleware"
	"ai-ops/internal/repository"
	"ai-ops/internal/services"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	// 初始化数据库
	dbPath := "./data/ai-ops.db"
	if err := database.InitDatabase(dbPath); err != nil {
		log.Fatalf("数据库初始化失败: %v", err)
	}
	defer database.CloseDatabase()

	log.Println("数据库初始化成功:", dbPath)

	// 初始化仓库和服务
	hostRepo := repository.NewHostRepository()
	hostService := services.NewHostService(hostRepo)

	// 设置 Gin 模式
	gin.SetMode(gin.ReleaseMode)
	r := gin.Default()

	// 加载静态文件
	r.Static("/static", "./web/static")
	r.LoadHTMLGlob("web/templates/*")

	// 中间件
	r.Use(middleware.CORS())

	// 初始化处理器
	hostHandler := handlers.NewHostHandler(hostService)

	// 前端路由
	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "dashboard.html", gin.H{
			"title": "智能运维管理平台",
		})
	})

	r.GET("/hosts", func(c *gin.Context) {
		c.HTML(http.StatusOK, "hosts.html", gin.H{
			"title": "主机管理",
		})
	})

	r.GET("/test", func(c *gin.Context) {
		c.HTML(http.StatusOK, "test-api.html", gin.H{})
	})

	// API 路由
	api := r.Group("/api/v1")
	{
		// 主机管理 API
		hosts := api.Group("/hosts")
		{
			hosts.GET("", hostHandler.ListHosts)
			hosts.POST("", hostHandler.CreateHost)
			hosts.GET("/:id", hostHandler.GetHost)
			hosts.PUT("/:id", hostHandler.UpdateHost)
			hosts.DELETE("/:id", hostHandler.DeleteHost)
			hosts.POST("/:id/check", hostHandler.CheckHost)
		}

		// 仪表盘 API
		api.GET("/dashboard/stats", hostHandler.GetDashboardStats)
	}

	log.Println("服务器启动在 :8080")
	log.Fatal(r.Run(":8080"))
}
