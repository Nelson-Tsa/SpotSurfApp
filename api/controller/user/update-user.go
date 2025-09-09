package user

import (
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

func (h *UserHandler) UpdateUser(ctx *gin.Context) {
	userRaw, exists := ctx.Get("user")
	if !exists {
		ctx.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	currentUser := userRaw.(model.Users)
	var updates map[string]interface{}

	if err := ctx.ShouldBindJSON(&updates); err != nil {
		ctx.JSON(400, gin.H{"error": "Invalid data"})
		return
	}

	delete(updates, "password")

	if err := h.DB.Model(&currentUser).Updates(updates).Error; err != nil {
		ctx.JSON(500, gin.H{"error": "Failed to update user"})
		return
	}

	ctx.JSON(200, gin.H{"message": "User updated successfully"})
}
