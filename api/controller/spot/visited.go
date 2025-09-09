package spot

import (
	"fmt"
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
	fmt.Println(" AddVisited called")

	userID, ok := getUserIDFromContext(c)
	if !ok {
		fmt.Println(" Authentication failed in AddVisited")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	fmt.Printf(" Authentication successful, userID: %d\n", userID)

	var req struct {
		SpotID int `json:"spot_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		fmt.Printf(" JSON binding error: %v\n", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	fmt.Printf(" Adding visit for user %d to spot %d\n", userID, req.SpotID)

	visited := model.Visited{UserID: userID, SpotID: req.SpotID}
	if err := h.DB.Create(&visited).Error; err != nil {
		fmt.Printf(" Database error: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	fmt.Printf(" Visit recorded successfully with ID: %d\n", visited.ID)
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
