package middlewares

import (
	"authentication-api/db"
	"authentication-api/models"
	"errors"
	"github.com/gin-gonic/gin"
	"net/http"
	"strconv"
)

func getCurrentUserFromContext(c *gin.Context) (*models.User, error) {
	userID, exists := c.Get("user_id")
	if !exists {
		return nil, errors.New("user not found in context")
	}

	user := models.User{}
	if err := db.DB.First(&user, userID).Error; err != nil {
		return nil, errors.New("user not found in database")

	}
	return &user, nil
}

func OwnerMiddleware(resource string, model models.IModel) gin.HandlerFunc {
	return func(c *gin.Context) {
		user, err := getCurrentUserFromContext(c)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "forbidden"})
			return
		}

		// Récupérer l'ID de la ressource depuis les paramètres de la requête
		resourceID := c.Param("id")
		if resourceID == "" {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "missing resource ID"})
			return
		}

		id, err := strconv.ParseUint(resourceID, 10, 32)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "invalid resource ID"})
			return
		}

		switch m := model.(type) {
		case *models.User:
			if err := db.DB.First(m, id).Error; err != nil {
				c.AbortWithStatusJSON(http.StatusNotFound, gin.H{"error": "resource not found"})
				return
			}
			if !m.IsOwner(user.ID) {
				c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "forbidden"})
				return
			}
		default:
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "unsupported resource type"})
			return
		}

		c.Next()
	}
}
