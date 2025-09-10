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
		// publicUserRoutes.GET("/spot/:id", handler.GetSpotByID)

		// Routes publiques pour les compteurs (pas besoin d'auth pour voir le nombre de likes)
		publicUserRoutes.GET("/likes/:id", handler.GetLikesCount)
	}

	// Routes protégées pour les likes (authentification requise)
	protectedSpotRoutes := router.Group("/api/spot")
	protectedSpotRoutes.Use(userHandler.AuthRequired)
	{
		protectedSpotRoutes.POST("/like/:id", handler.ToggleLike)
		protectedSpotRoutes.GET("/isliked/:id", handler.IsLiked)
		protectedSpotRoutes.GET("/favorites", handler.GetUserFavorites)
	}
}
