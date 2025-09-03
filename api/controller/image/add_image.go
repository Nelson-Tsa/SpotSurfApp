package image

import (
	"io/ioutil"
	"net/http"
	"strconv"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type ImageHandler struct {
	DB *gorm.DB
}

func (h *ImageHandler) AddImageToSpot(ctx *gin.Context) {
	spotID := ctx.Param("id")

	file, _, err := ctx.Request.FormFile("image")
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Image requise"})
		return
	}
	defer file.Close()

	imageBytes, err := ioutil.ReadAll(file)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lecture image"})
		return
	}

	image := model.Images{
		SpotID: atoi(spotID),
		ImageData:  imageBytes,
	}
	if err := h.DB.Create(&image).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, image)
}

func atoi(s string) int {
	n, _ := strconv.Atoi(s)
	return n
}
