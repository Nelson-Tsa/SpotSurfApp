package user

import (
	"net/http"
	"github.com/gin-gonic/gin"
)


func Logout(ctx *gin.Context) {
	// Réécriture du cookie avec expiration immédiate
	ctx.SetCookie(
		"surf-spot-token", // doit correspondre à setAuthCookie
		"",                // valeur vide
		-1,                // maxAge négatif => suppression immédiate
		"/",               // chemin
		"",                // domaine (vide = domaine courant)
		false,             // Secure (mettre true en prod HTTPS)
		true,              // HttpOnly
	)

	ctx.JSON(http.StatusOK, gin.H{
		"message": "logout success",
	})
}
