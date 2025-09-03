package spot

import (
	"net/http"

	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

func (h *SpotHandler) GetAllSpots(ctx *gin.Context) {
	var spots []model.Spots

	// Charge les spots ET leurs images associées
	if err := h.DB.Preload("Images").Find(&spots).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, spots)
}
