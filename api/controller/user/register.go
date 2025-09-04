package user

import (
	"net/http"
	"regexp"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func (h *UserHandler) RegisterUsers(ctx *gin.Context) {

	var data map[string]string

	if ctx.BindJSON(&data) != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error": "Failed to read body",
		})
		return
	}

	if data["email"] == "" || data["password"] == "" || data["name"] == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Missing required fields"})
		return
	}

	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(data["email"]) {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid email format"})
		return
	}

	password := data["password"]

	lengthOK := len(password) >= 8
	upperOK := regexp.MustCompile(`[A-Z]`).MatchString(password)
	lowerOK := regexp.MustCompile(`[a-z]`).MatchString(password)
	digitOK := regexp.MustCompile(`\d`).MatchString(password)

	if !(lengthOK && upperOK && lowerOK && digitOK) {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error": "Password must be at least 8 characters, include upper/lowercase and a number",
		})
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(data["password"]), 14)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error": "Failed to hash password",
		})
		return
	}

	role := data["role"]
	if role == "" {
		role = "user"
	}

	user := model.Users{
		Name:     data["name"],
		Email:    data["email"],
		Password: hash,
		Role:     role,
	}

	result := h.DB.Create(&user)
	if result.Error != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"error": "Failed to create user",
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"id":    user.ID,
		"name":  user.Name,
		"email": user.Email,
		"role":  user.Role,
	})
}
