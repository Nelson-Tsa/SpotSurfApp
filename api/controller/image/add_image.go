package image

import (
	"encoding/base64"
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
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Format JSON invalide"})
		return
	}

	imageBytes, err := base64.StdEncoding.DecodeString(req.ImageData)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Image base64 invalide"})
		return
	}

	image := model.Images{
		SpotID:    int(req.SpotID), // conversion explicite
		ImageData: imageBytes,
	}
	if err := h.DB.Create(&image).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{"message": "Image ajoutée"})
}
