package spot

import (
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type SpotHandler struct {
	DB *gorm.DB
}

func SpotRoutes(router *gin.Engine, db *gorm.DB) {
	handler := &SpotHandler{DB: db}

	publicUserRoutes := router.Group("/api/spot")
	{
		publicUserRoutes.POST("/create", handler.CreateSpot)
		publicUserRoutes.GET("/spots", handler.GetAllSpots)
		publicUserRoutes.PUT("/update", handler.UpdateSpot)
		publicUserRoutes.DELETE("/delete", handler.DeleteSpot)
		// publicUserRoutes.GET("/spot/:id", handler.GetSpotByID)

		publicUserRoutes.POST("/like/:id", handler.ToggleLike)
		publicUserRoutes.GET("/likes/:id", handler.GetLikesCount)


	}

	// protectedUserRoutes := router.Group("/api/users")
	// protectedUserRoutes.Use(middleware.AuthMiddleware())
	// {
	// 	protectedUserRoutes.GET("/profile", controller.GetProfile)
	// 	protectedUserRoutes.PUT("/profile", controller.UpdateProfile)
	// }
}
