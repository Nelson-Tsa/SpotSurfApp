package user

import (
	"log"
	"net/http"
	"strconv"
	"surf_spots_app/config"
	"surf_spots_app/model"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

func (h *UserHandler) LoginUsers(ctx *gin.Context) {
	configEnv, err := config.LoadConfig()
	if err != nil {
		log.Fatal("Cannot load config:", err)
	}

	var data map[string]string

	if err := ctx.ShouldBindJSON(&data); err != nil {
		ctx.JSON(400, gin.H{"error": "Invalid JSON"})
		return
	}

	var user model.Users

	h.DB.Where("email = ?", data["email"]).First(&user)

	if user.ID == 0 {
		ctx.JSON(401, gin.H{"error": "Invalid email"})
		return
	}

	if err := bcrypt.CompareHashAndPassword(user.Password, []byte(data["password"])); err != nil {
		ctx.JSON(401, gin.H{"error": "Invalid password"})
		return
	}

	claims := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.RegisteredClaims{
		Subject:   strconv.Itoa(int(user.ID)),
		Issuer:    "surf-spot-app",
		ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour * 24 * 7)),
		IssuedAt:  jwt.NewNumericDate(time.Now()),
	})

	token, err := claims.SignedString([]byte(configEnv.JwtToken))
	if err != nil {
		ctx.JSON(500, gin.H{"error": "Could not generate token"})
		return
	}

	cookie := setAuthCookie(token)
	http.SetCookie(ctx.Writer, cookie)

	ctx.JSON(200, gin.H{"message": "Logged in successfully"})
}

func setAuthCookie(token string) *http.Cookie {
	return &http.Cookie{
		Name:     "surf-spot-token",
		Path:     "/",
		Value:    token,
		Expires:  time.Now().Add(time.Hour * 24 * 7), // 7 days
		HttpOnly: true,
		SameSite: http.SameSiteLaxMode,
		Secure:   false, // Mettre à true en production avec HTTPS
	}
}
