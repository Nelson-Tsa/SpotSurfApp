package spot

import (
	"surf_spots_app/controller/user"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type SpotHandler struct {
	DB *gorm.DB
}

func SpotRoutes(router *gin.Engine, db *gorm.DB) {
	handler := &SpotHandler{DB: db}
	userHandler := &user.UserHandler{DB: db}

	publicUserRoutes := router.Group("/api/spot")
	{
		publicUserRoutes.POST("/create", handler.CreateSpot)
		publicUserRoutes.GET("/spots", handler.GetAllSpots)
		publicUserRoutes.PUT("/update", handler.UpdateSpot)
		publicUserRoutes.DELETE("/delete", handler.DeleteSpot)
	}

	protectedUserRoutes := router.Group("/api/spot")
	protectedUserRoutes.Use(userHandler.AuthRequired)
	{
		protectedUserRoutes.GET("/my-spots", handler.GetMySpots)
	}
}
