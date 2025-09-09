package spot

import (
	"net/http"
	"strconv"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

func (h *SpotHandler) CreateSpot(ctx *gin.Context) {
	var req struct {
		Name        string `json:"name"`
		City        string `json:"city"`
		Description string `json:"description"`
		Level       int    `json:"level"`      // <-- int ici
		Difficulty  int    `json:"difficulty"` // <-- int ici
		Gps         string `json:"gps"`
	}
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error":   "Format JSON invalide",
			"details": err.Error(), // Ajoute ce détail
		})
		return
	}

	// Récupère l'ID utilisateur depuis le contexte d'authentification
	userID := ctx.GetInt("user_id")
	if userID == 0 {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "Utilisateur non authentifié"})
		return
	}

	spot := model.Spots{
		Name:        req.Name,
		City:        req.City,
		Description: req.Description,
		Level:       strconv.Itoa(req.Level),      // conversion int -> string
		Difficulty:  strconv.Itoa(req.Difficulty), // conversion int -> string
		Gps:         req.Gps,
		UserID:      userID,
		LikeCount:   0,
	}
	if err := h.DB.Create(&spot).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{"id": spot.ID})
}

// Helper pour convertir string en int
func atoi(s string) int {
	n, _ := strconv.Atoi(s)
	return n
}
