package spot

import (
	"net/http"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

func (h *SpotHandler) DeleteSpot(ctx *gin.Context) {
	spotID := ctx.Param("id")
	if spotID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "ID du spot requis"})
		return
	}

	// Récupère le spot existant
	var spot model.Spots
	if err := h.DB.First(&spot, spotID).Error; err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Spot non trouvé"})
		return
	}

	// Récupère les informations utilisateur depuis le middleware d'authentification
	role := ctx.GetString("role")
	currentUserID := ctx.GetInt("user_id")

	// Vérifie l'autorisation : admin ou propriétaire du spot
	if role != "admin" && spot.UserID != currentUserID {
		ctx.JSON(http.StatusForbidden, gin.H{
			"error": "Non autorisé - vous ne pouvez supprimer que vos propres spots ou être admin",
		})
		return
	}

	// Supprime d'abord les images associées
	if err := h.DB.Where("spot_id = ?", spot.ID).Delete(&model.Images{}).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la suppression des images"})
		return
	}

	// Supprime les likes associés
	if err := h.DB.Where("spot_id = ?", spot.ID).Delete(&model.Likes{}).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la suppression des likes"})
		return
	}

	// Supprime les visites associées
	if err := h.DB.Where("spot_id = ?", spot.ID).Delete(&model.Visited{}).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la suppression des visites"})
		return
	}

	// Supprime finalement le spot
	if err := h.DB.Delete(&spot).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la suppression du spot"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Spot supprimé avec succès",
		"spot_id": spotID,
	})
}
