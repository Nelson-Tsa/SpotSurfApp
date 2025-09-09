package user

import (
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
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

	if newPassword, hashPassword := updates["new_password"].(string); hashPassword {
		currentPassword, hasCurrentPassword := updates["current_password"].(string)
		if !hasCurrentPassword {
			ctx.JSON(400, gin.H{"error": "Current password is required to change password"})
			return
		}

		if err := bcrypt.CompareHashAndPassword([]byte(currentUser.Password), []byte(currentPassword)); err != nil {
			ctx.JSON(400, gin.H{"error": "Current password is incorrect"})
			return
		}

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
		if err != nil {
			ctx.JSON(500, gin.H{"error": "Failed to hash password"})
			return
		}

		updates["password"] = string(hashedPassword)
	}

	delete(updates, "current_password")
	delete(updates, "new_password")

	if err := h.DB.Model(&currentUser).Updates(updates).Error; err != nil {
		ctx.JSON(500, gin.H{"error": "Failed to update user"})
		return
	}

	ctx.JSON(200, gin.H{"message": "User updated successfully"})
}
