package spot

import (
	"strconv"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

func (h *SpotHandler) ToggleLike(ctx *gin.Context) {
	// Récupérer l'utilisateur authentifié
	userID := ctx.GetInt("user_id")
	if userID == 0 {
		ctx.JSON(401, gin.H{"error": "Non authentifié"})
		return
	}

	spotID, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(400, gin.H{"error": "ID spot invalide"})
		return
	}

	var like model.Likes
	err = h.DB.Where("user_id = ? AND spot_id = ?", userID, spotID).First(&like).Error

	if err != nil {
		// Pas de like -> créer
		h.DB.Create(&model.Likes{UserID: int64(userID), SpotID: int64(spotID)})
		ctx.JSON(200, gin.H{"liked": true})
	} else {
		// Like existe -> supprimer
		h.DB.Delete(&like)
		ctx.JSON(200, gin.H{"liked": false})
	}
}

func (h *SpotHandler) IsLiked(ctx *gin.Context) {
	userID := ctx.GetInt("user_id")
	if userID == 0 {
		ctx.JSON(401, gin.H{"error": "Non authentifié"})
		return
	}

	spotID, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(400, gin.H{"error": "ID spot invalide"})
		return
	}

	var like model.Likes
	err = h.DB.Where("user_id = ? AND spot_id = ?", userID, spotID).First(&like).Error

	ctx.JSON(200, gin.H{"isLiked": err == nil})
}

func (h *SpotHandler) GetLikesCount(ctx *gin.Context) {
	spotID, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(400, gin.H{"error": "ID spot invalide"})
		return
	}

	var count int64
	h.DB.Model(&model.Likes{}).Where("spot_id = ?", spotID).Count(&count)

	ctx.JSON(200, gin.H{"count": count})
}

func (h *SpotHandler) GetUserFavorites(ctx *gin.Context) {
	userID := ctx.GetInt("user_id")
	if userID == 0 {
		ctx.JSON(401, gin.H{"error": "Non authentifié"})
		return
	}

	var spots []model.Spots
	err := h.DB.Joins("JOIN likes ON spots.id = likes.spot_id").
		Where("likes.user_id = ?", userID).
		Preload("Images").
		Find(&spots).Error

	if err != nil {
		ctx.JSON(500, gin.H{"error": "Erreur lors de la récupération des favoris"})
		return
	}

	ctx.JSON(200, spots)
}
