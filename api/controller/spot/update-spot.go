package spot

import (
	"encoding/base64"
	"net/http"
	"strconv"
	"surf_spots_app/model"

	"github.com/gin-gonic/gin"
)

func (h *SpotHandler) UpdateSpot(ctx *gin.Context) {
	spotID := ctx.Param("id")
	if spotID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "ID du spot requis"})
		return
	}

	var req struct {
		Name        string   `json:"name"`
		City        string   `json:"city"`
		Description string   `json:"description"`
		Level       int      `json:"level"`
		Difficulty  int      `json:"difficulty"`
		Gps         string   `json:"gps"`
		Images      []string `json:"images"`
	}

	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Format JSON invalide", "details": err.Error()})
		return
	}

	// Récupère le spot existant
	var spot model.Spots
	if err := h.DB.First(&spot, spotID).Error; err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "Spot non trouvé"})
		return
	}

	// Récupère les informations utilisateur depuis le middleware d'authentification
	role := ctx.GetString("role")
	currentUserID := ctx.GetInt("user_id")

	// Vérifie l'autorisation : admin ou propriétaire du spot
	if role != "admin" && spot.UserID != currentUserID {
		ctx.JSON(http.StatusForbidden, gin.H{
			"error": "Non autorisé - vous ne pouvez modifier que vos propres spots ou être admin",
		})
		return
	}

	// Met à jour les champs du spot
	if req.Name != "" {
		spot.Name = req.Name
	}
	if req.City != "" {
		spot.City = req.City
	}
	if req.Description != "" {
		spot.Description = req.Description
	}
	if req.Level > 0 {
		spot.Level = strconv.Itoa(req.Level)
	}
	if req.Difficulty > 0 {
		spot.Difficulty = strconv.Itoa(req.Difficulty)
	}
	if req.Gps != "" {
		spot.Gps = req.Gps
	}

	if err := h.DB.Save(&spot).Error; err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la mise à jour du spot"})
		return
	}

	// --- Synchronisation des images ---
	// Récupère toutes les images existantes
	var existingImages []model.Images
	h.DB.Where("spot_id = ?", spot.ID).Find(&existingImages)

	if len(req.Images) == 0 {
		// Si aucune image n'est envoyée, supprime toutes les images existantes
		for _, img := range existingImages {
			h.DB.Delete(&img)
		}
	} else {
		// Map pour retrouver rapidement les images existantes
		existingMap := make(map[string]model.Images)
		for _, img := range existingImages {
			existingMap[string(img.ImageData)] = img
		}

		// Supprime les images qui ne sont plus dans la nouvelle liste
		for _, img := range existingImages {
			found := false
			for _, newImg := range req.Images {
				decodedImg, err := base64.StdEncoding.DecodeString(newImg)
				if err != nil {
					ctx.JSON(http.StatusBadRequest, gin.H{"error": "Erreur de décodage de l'image"})
					return
				}
				if string(img.ImageData) == string(decodedImg) {
					found = true
					break
				}
			}
			if !found {
				h.DB.Delete(&img)
			}
		}

		// Ajoute les nouvelles images qui n'existaient pas
		for _, newImg := range req.Images {
			decodedImg, err := base64.StdEncoding.DecodeString(newImg)
			if err != nil {
				ctx.JSON(http.StatusBadRequest, gin.H{"error": "Erreur de décodage de l'image"})
				return
			}
			if _, ok := existingMap[string(decodedImg)]; !ok {
				// Ajoute l'image
				h.DB.Create(&model.Images{
					SpotID:    spot.ID,
					ImageData: decodedImg,
				})
			}
		}
	}

	// Recharge le spot avec ses images à jour
	var updatedSpot model.Spots
	h.DB.Preload("Images").First(&updatedSpot, spot.ID)

	ctx.JSON(http.StatusOK, gin.H{
		"message": "Spot mis à jour avec succès",
		"spot":    updatedSpot,
	})
}
