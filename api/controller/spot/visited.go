package spot

import (
	"net/http"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

func getUserIDFromContext(c *gin.Context) (int, bool) {
	userRaw, exists := c.Get("user")
	if !exists {
		return 0, false
	}
	user, ok := userRaw.(model.Users)
	if !ok {
		return 0, false
	}
	return user.ID, true
}

func (h *SpotHandler) AddVisited(c *gin.Context) {
	userID, ok := getUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req struct {
		SpotID int `json:"spot_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	visited := model.Visited{UserID: userID, SpotID: req.SpotID}
	if err := h.DB.Create(&visited).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, visited)
}

func (h *SpotHandler) GetVisited(c *gin.Context) {
	userID, ok := getUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var visited []model.Visited
	if err := h.DB.
		Preload("Spot").
		Where("user_id = ?", userID).
		Order("id DESC").
		Limit(20).
		Find(&visited).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, visited)
}

func (h *SpotHandler) DeleteVisited(c *gin.Context) {
	userID, ok := getUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	visitedID := c.Param("id")

	if err := h.DB.
		Where("id = ? AND user_id = ?", visitedID, userID).
		Delete(&model.Visited{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Visited entry deleted"})
}

func (h *SpotHandler) DeleteVisitedBySpot(c *gin.Context) {
	userID, ok := getUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	spotID := c.Param("spotId")

	if err := h.DB.
		Where("spot_id = ? AND user_id = ?", spotID, userID).
		Delete(&model.Visited{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Visited entry deleted by spot_id"})
}
