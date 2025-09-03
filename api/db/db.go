package db

import (
	"log"
	"surf_spots_app/model"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func InitDB(url string) *gorm.DB {
	// Initialize the database connection
	db, err := gorm.Open(postgres.Open(url), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Auto-migrate the models
	err = db.AutoMigrate(&model.Users{}, &model.Spots{}, &model.Images{}, &model.Likes{}, &model.Visited{})
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	return db
}
