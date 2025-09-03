package spot

import (
	"io/ioutil"
	"net/http"
	"strconv"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

func (h *SpotHandler) CreateSpot(ctx *gin.Context) {
	// Récupère les champs du formulaire
	name := ctx.PostForm("name")
	city := ctx.PostForm("city")
	description := ctx.PostForm("description")
	level := ctx.PostForm("level")
	difficulty := ctx.PostForm("difficulty")
	gps := ctx.PostForm("gps")
	userID := ctx.PostForm("user_id")

	// Récupère le fichier image
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

	// Crée le spot
	spot := model.Spots{
		Name:        name,
		City:        city,
		Description: description,
		Level:       level,
		Difficulty:  difficulty,
		Gps:         gps,
		UserID:      atoi(userID),
		LikeCount:   0,
	}
	if err := h.DB.Create(&spot).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Crée l'image et lie au spot
	image := model.Images{
		SpotID: spot.ID,
		ImageData:  imageBytes,
	}
	if err := h.DB.Create(&image).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, spot)
}

// Helper pour convertir string en int
func atoi(s string) int {
	n, _ := strconv.Atoi(s)
	return n
}
