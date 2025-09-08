package user

import (
	"net/http"
	"strconv"
	"surf_spots_app/config"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"gorm.io/gorm"
)

// AuthRequired est un middleware Gin qui vérifie le JWT et récupère l'utilisateur
func AuthRequired(db *gorm.DB) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		configEnv, err := config.LoadConfig()
		if err != nil {
			panic("Failed to load config")
		}

		cookie, err := ctx.Cookie("surf-spot-token")
		if err != nil {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": "Missing token"})
			ctx.Abort()
			return
		}

		token, err := jwt.ParseWithClaims(cookie, &jwt.RegisteredClaims{}, func(t *jwt.Token) (interface{}, error) {
			return []byte(configEnv.JwtToken), nil
		})
		if err != nil || !token.Valid {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
			ctx.Abort()
			return
		}

		claims := token.Claims.(*jwt.RegisteredClaims)
		userID, err := strconv.Atoi(claims.Subject)
		if err != nil {
			ctx.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token format"})
			ctx.Abort()
			return
		}

		var user model.Users
		if err := db.Where("id = ?", userID).First(&user).Error; err != nil {
			ctx.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			ctx.Abort()
			return
		}

		ctx.Set("user", user)
		ctx.Next()
	}
}
