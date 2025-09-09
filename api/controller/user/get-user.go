package user

import (
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

func (h *UserHandler) GetUser(ctx *gin.Context) {
	userRaw, exists := ctx.Get("user")
	if !exists {
		ctx.JSON(401, gin.H{"error": "Unauthorized"})
		return
	}

	user, ok := userRaw.(model.Users)
	if !ok {
		ctx.JSON(500, gin.H{"error": "Internal server error"})
		return
	}

	ctx.JSON(200, gin.H{
		"user": user,
		
	})
}
