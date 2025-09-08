package user

import (
	"net/http"
	"strconv"
	"surf_spots_app/config"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func (h *UserHandler) AuthRequired(ctx *gin.Context) {
	configEnv, err := config.LoadConfig()
	if err != nil {
		panic("Failed to load config")
	}

	cookie, err := ctx.Cookie("surf-spot-token")
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{
			"error": "Missing token",
		})
		return
	}

	token, err := jwt.ParseWithClaims(cookie, &jwt.RegisteredClaims{}, func(t *jwt.Token) (interface{}, error) {
		return []byte(configEnv.JwtToken), nil
	})
	if err != nil || !token.Valid {
		ctx.JSON(http.StatusUnauthorized, gin.H{
			"error": "Unauthorized",
		})
		return
	}

	claims := token.Claims.(*jwt.RegisteredClaims)

	// Convertir le Subject (ID utilisateur) en entier
	userID, err := strconv.Atoi(claims.Subject)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{
			"error": "Invalid token format",
		})
		return
	}

	var user model.Users

	if err := h.DB.Where("id = ?", userID).First(&user).Error; err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{
			"error": "User not found",
		})
		return
	}

	ctx.Set("user", user)
	ctx.Next()
}
