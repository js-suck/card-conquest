package middlewares

import (
	"authentication-api/db"
	"authentication-api/models"
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetCurrentUserFromContext(c *gin.Context) (*models.User, error) {
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
		user, err := GetCurrentUserFromContext(c)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "forbidden"})
			return
		}

		// if user is admin, skip the owner check
		if user.IsAdmin() {
			c.Next()
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
		newModel := model.New()

		switch m := newModel.(type) {
		default:
			if err := db.DB.First(m, id).Error; err != nil {
				c.AbortWithStatusJSON(http.StatusNotFound, gin.H{"error": "resource not found"})
				return
			}
			if !m.IsOwner(user.ID) && !user.IsAdmin() {
				c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "forbidden"})
				return
			}
			c.Next()
		}

		c.Next()
	}
}
