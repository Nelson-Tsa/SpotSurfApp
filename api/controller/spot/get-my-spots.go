package spot

import (
	"net/http"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

func (h *SpotHandler) GetMySpots(ctx *gin.Context) {
	// Récupérer l'utilisateur depuis le middleware d'authentification
	userRaw, exists := ctx.Get("user")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	user, ok := userRaw.(model.Users)
	if !ok {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
		return
	}

	// Récupérer uniquement les spots de cet utilisateur
	var spots []model.Spots
	if err := h.DB.Where("user_id = ?", user.ID).Preload("Images").Find(&spots).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, spots)
}
