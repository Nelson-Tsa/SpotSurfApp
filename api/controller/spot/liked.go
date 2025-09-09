package spot

import (

	"strconv"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

func (h *SpotHandler) ToggleLike(ctx *gin.Context) {
    user := ctx.MustGet("user").(model.Users)
    spotID, _ := strconv.Atoi(ctx.Param("id"))

    var like model.Likes
    err := h.DB.Where("user_id = ? AND spot_id = ?", user.ID, spotID).First(&like).Error

    if err != nil {
        // Pas de like -> créer
        h.DB.Create(&model.Likes{UserID: int64(user.ID), SpotID: int64(spotID)})
        ctx.JSON(200, gin.H{"liked": true})
    } else {
        // Like existe -> supprimer
        h.DB.Delete(&like)
        ctx.JSON(200, gin.H{"liked": false})
    }
}

func (h *SpotHandler) GetLikesCount(ctx *gin.Context) {
    spotID, _ := strconv.Atoi(ctx.Param("id"))
    
    var count int64
    h.DB.Model(&model.Likes{}).Where("spot_id = ?", spotID).Count(&count)
    
    ctx.JSON(200, gin.H{"count": count})
}
