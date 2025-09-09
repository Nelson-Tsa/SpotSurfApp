package image

import (
	"encoding/base64"
	"fmt"
	"net/http"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type ImageHandler struct {
	DB *gorm.DB
}

func (h *ImageHandler) AddImageToSpot(ctx *gin.Context) {
	var req struct {
		SpotID    uint   `json:"spot_id"`
		ImageData string `json:"image_data"` // base64
	}
	if err := ctx.ShouldBindJSON(&req); err != nil {
		fmt.Printf("❌ Error binding JSON: %v\n", err)
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Format JSON invalide"})
		return
	}

	fmt.Printf("📸 Received image upload request for spot ID: %d\n", req.SpotID)

	imageBytes, err := base64.StdEncoding.DecodeString(req.ImageData)
	if err != nil {
		fmt.Printf("❌ Error decoding base64: %v\n", err)
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Image base64 invalide"})
		return
	}

	fmt.Printf("✅ Base64 decoded successfully, image size: %d bytes\n", len(imageBytes))

	image := model.Images{
		SpotID:    int(req.SpotID), // conversion explicite
		ImageData: imageBytes,
	}
	if err := h.DB.Create(&image).Error; err != nil {
		fmt.Printf("❌ Database error: %v\n", err)
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	fmt.Printf("✅ Image saved to database with ID: %d\n", image.ID)
	ctx.JSON(http.StatusCreated, gin.H{"message": "Image ajoutée"})
}
