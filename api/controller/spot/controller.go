package spot

import (
	"surf_spots_app/controller/image"
	"surf_spots_app/controller/user"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type SpotHandler struct {
	DB *gorm.DB
}

func (handler *SpotHandler) AddImageToSpot(c *gin.Context) {
	// Code de la méthode AddImageToSpot
}

func SpotRoutes(router *gin.Engine, db *gorm.DB) {
	handler := &SpotHandler{DB: db}
	userHandler := &user.UserHandler{DB: db}
	imageHandler := &image.ImageHandler{DB: db}

	// Routes publiques (lecture seule)
	publicSpotRoutes := router.Group("/api/spot")
	{
		publicSpotRoutes.GET("/spots", handler.GetAllSpots)
		// publicSpotRoutes.GET("/spot/:id", handler.GetSpotByID)
	}

	// Routes protégées (nécessitent une authentification)
	protectedSpotRoutes := router.Group("/api/spot")
	protectedSpotRoutes.Use(userHandler.AuthRequired)
	{
		protectedSpotRoutes.POST("/create", handler.CreateSpot)
		protectedSpotRoutes.PUT("/update/:id", handler.UpdateSpot)
		protectedSpotRoutes.DELETE("/delete/:id", handler.DeleteSpot)
		protectedSpotRoutes.POST("/images", imageHandler.AddImageToSpot)
	}
}
