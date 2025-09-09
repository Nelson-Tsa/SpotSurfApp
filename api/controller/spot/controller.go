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

		// TEMPORAIRE: Routes publiques pour les tests
		publicUserRoutes.GET("/likes/:id", handler.GetLikesCount)
		publicUserRoutes.POST("/like/:id", handler.ToggleLike) // Temporaire
	}

	// Routes protégées pour les likes (authentification requise)
	// TODO: Remettre ToggleLike ici une fois l'authentification Dio configurée
	protectedSpotRoutes := router.Group("/api/spot")
	protectedSpotRoutes.Use(userHandler.AuthRequired)
	{
		// protectedSpotRoutes.POST("/like/:id", handler.ToggleLike) // À remettre plus tard
	}
}
