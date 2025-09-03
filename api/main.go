package main

import (
	"fmt"
	"log"
	"surf_spots_app/config"
	"surf_spots_app/controller/image"
	"surf_spots_app/controller/spot"
	"surf_spots_app/controller/user"
	"surf_spots_app/db"

	"github.com/gin-gonic/gin"
)

func main() {
	configEnv, err := config.LoadConfig()
	if err != nil {
		log.Fatal("Cannot load config:", err)
	}

	r := gin.Default()

	db := db.InitDB(configEnv.DatabaseURL)

	imageHandler := &image.ImageHandler{DB: db}

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "Hello, World!",
		})
	})




	// Routes
	user.UserRoutes(r, db)
	spot.SpotRoutes(r, db)
	r.POST("/api/spot/add-image/:id", imageHandler.AddImageToSpot)

	err = r.Run(fmt.Sprintf(":%s", configEnv.Port))
	if err != nil {
		log.Fatal("Failed to run server:", err)
	}
}
