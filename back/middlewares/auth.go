package middlewares

import (
	"authentication-api/models"
	"authentication-api/permissions"
	"authentication-api/utils"
	"fmt"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"net/http"
)

func AuthenticationMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString := c.GetHeader("Authorization")
		fmt.Println(tokenString)

		if tokenString == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authentication token"})
			c.Abort()
			return
		}

		claims, err := utils.VerifyToken(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid authentication token"})
			c.Abort()
			return
		}

		c.Set("user_id", claims["user_id"])
		c.Next()
	}
}

func PermissionMiddleware(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		idFloat, _ := c.Get("user_id")

		// Assert idFloat to float64
		idFloat64, ok := idFloat.(float64)
		if !ok {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			c.Abort()
			return
		}

		idInt := int(idFloat64)

		// Convert idInt to uint
		idUint := uint(idInt)

		fmt.Println(idUint)

		user := models.User{}
		result := db.First(&user, idUint)
		if result.Error != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			c.Abort()
			return
		}

		canAccess := false

		if user.Role == "admin" {
			canAccess = true
		}

		if !canAccess {
			c.JSON(http.StatusForbidden, gin.H{"error": "You do not have permission to access this resource"})
			c.Abort()
			return
		}

		// create a map of permissions
		permissions := []permissions.Permission{
			{
				Key:       permissions.PermissionCreateUser,
				CanAccess: true,
			},
			{
				Key:       permissions.PermissionDeleteUser,
				CanAccess: true,
			},
		}

		c.Set("permissions", permissions)

		c.Next()
	}
}
