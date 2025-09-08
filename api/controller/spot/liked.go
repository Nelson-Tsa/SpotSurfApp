package spot

import (
	"net/http"
	"strconv"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

// LikeSpot ajoute un like
func (h *SpotHandler) LikeSpot(c *gin.Context) {
	spotID, _ := strconv.Atoi(c.Param("id"))
	userID, _ := strconv.Atoi(c.Query("user_id")) // ⚠️ provisoire, à remplacer par JWT plus tard

	var existing model.Likes
	if err := h.DB.Where("spot_id = ? AND user_id = ?", spotID, userID).First(&existing).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Already liked"})
		return
	}

	newLike := model.Likes{
		SpotID: spotID,
		UserID: userID,
	}

	if err := h.DB.Create(&newLike).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not like spot"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Spot liked"})
}

// UnlikeSpot supprime un like
func (h *SpotHandler) UnlikeSpot(c *gin.Context) {
	spotID, _ := strconv.Atoi(c.Param("id"))
	userID, _ := strconv.Atoi(c.Query("user_id"))

	if err := h.DB.Where("spot_id = ? AND user_id = ?", spotID, userID).Delete(&model.Likes{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not unlike"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Spot unliked"})
}

// GetLikesCount retourne le nombre de likes
func (h *SpotHandler) GetLikesCount(c *gin.Context) {
	spotID, _ := strconv.Atoi(c.Param("id"))
	var count int64

	h.DB.Model(&model.Likes{}).Where("spot_id = ?", spotID).Count(&count)

	c.JSON(http.StatusOK, gin.H{"likes": count})
}
