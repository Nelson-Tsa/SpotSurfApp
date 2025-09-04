package spot

import (
	"net/http"
	"surf_spots_app/model" // <-- Ajoute ceci selon l'emplacement de ton modèle

	"github.com/gin-gonic/gin"
)

func (h *SpotHandler) DeleteSpot(ctx *gin.Context) {
	id := ctx.Param("id")

	// TODO: Vérifier que l'utilisateur est admin ou créateur du spot

	if err := h.DB.Delete(&model.Spots{}, id).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Suppression impossible"})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"message": "Spot supprimé"})
}
