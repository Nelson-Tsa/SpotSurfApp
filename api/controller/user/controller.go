package user

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type UserHandler struct {
	DB *gorm.DB
}

func UserRoutes(router *gin.Engine, db *gorm.DB) {
	handler := &UserHandler{DB: db}

	publicUserRoutes := router.Group("/api/users")
	{
		publicUserRoutes.POST("/register", handler.RegisterUsers)
		publicUserRoutes.POST("/login", handler.LoginUsers)
		publicUserRoutes.POST("/logout", Logout)
	}

	// protectedUserRoutes := router.Group("/api/users")
	// protectedUserRoutes.Use(middleware.AuthMiddleware())
	// {
	// 	protectedUserRoutes.GET("/profile", controller.GetProfile)
	// 	protectedUserRoutes.PUT("/profile", controller.UpdateProfile)
	// }
}
