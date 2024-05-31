package permissions

import (
	"authentication-api/db"
	"authentication-api/models"
	"github.com/gin-gonic/gin"
	"net/http"
)

type Permission struct {
	Key       string
	CanAccess bool
}

var AdminPermissions = []Permission{
	{
		Key:       PermissionAllAccess,
		CanAccess: true,
	},
}
var UserPermissions = []Permission{
	{
		Key:       PermissionReadeUser,
		CanAccess: true,
	},
	{
		Key:       PermissionUpdateUser,
		CanAccess: true,
	},
	{
		Key:       PermissionDeleteUser,
		CanAccess: true,
	},
	{
		Key:       PermissionCreateTags,
		CanAccess: false,
	},
	{
		Key:       PermissionUpdateTags,
		CanAccess: false,
	},
	{
		Key:       PermissionDeleteTags,
		CanAccess: false,
	},
	{
		Key:       PermissionReadTags,
		CanAccess: true,
	},
}

var OrganizerPermissions = []Permission{
	{
		Key:       PermissionReadeUser,
		CanAccess: true,
	},
	{
		Key:       PermissionCreateTags,
		CanAccess: true,
	},
	{
		Key:       PermissionUpdateTags,
		CanAccess: true,
	},
	{
		Key:       PermissionDeleteTags,
		CanAccess: true,
	},
	{
		Key:       PermissionReadTags,
		CanAccess: true,
	},
	{
		Key:       PermissionCreateUser,
		CanAccess: true,
	},
}

const (
	PermissionAllAccess  = "all_access"
	PermissionCreateUser = "create_user"
	PermissionDeleteUser = "delete_user"
	PermissionUpdateUser = "update_user"
	PermissionReadeUser  = "read_user"
	PermissionCreateTags = "create_tags"
	PermissionUpdateTags = "update_tags"
	PermissionDeleteTags = "delete_tags"
	PermissionReadTags   = "read_tags"
)

func CanAccess(permissions []Permission, key string) bool {
	for _, permission := range permissions {

		if permission.Key == PermissionAllAccess {
			return true

		}

		if permission.Key == key && permission.CanAccess {
			return true
		}
	}

	return false
}

func PermissionMiddleware(requiredPermission string) gin.HandlerFunc {
	return func(c *gin.Context) {
		idFloat, _ := c.Get("user_id")

		idFloat64, ok := idFloat.(float64)
		if !ok {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
			c.Abort()
			return
		}

		idInt := int(idFloat64)
		idUint := uint(idInt)

		user := models.User{}
		result := db.DB.First(&user, idUint)
		if result.Error != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
			c.Abort()
			return
		}

		var permissionsOfUser []Permission
		switch user.Role {
		case "admin":
			permissionsOfUser = AdminPermissions
		case "organizer":
			permissionsOfUser = OrganizerPermissions
		case "user":
			permissionsOfUser = UserPermissions
		}

		canAccess := false
		for _, perm := range permissionsOfUser {

			if perm.Key == PermissionAllAccess {
				canAccess = true
				break

			}

			if perm.Key == requiredPermission {
				canAccess = true
				break
			}
		}

		if !canAccess {
			c.JSON(http.StatusForbidden, gin.H{"error": "You do not have permission to access this resource"})
			c.Abort()
			return
		}

		// Optional: Check if the user is the owner of the resource
		resourceID := c.Param("tournamentID")
		if resourceID != "" {
			var tournament models.Tournament
			if err := db.DB.First(&tournament, resourceID).Error; err != nil {
				c.JSON(http.StatusNotFound, gin.H{"error": "Resource not found"})
				c.Abort()
				return
			}

			if !tournament.IsOwner(idUint) && user.Role != "admin" {
				c.JSON(http.StatusForbidden, gin.H{"error": "You are not the owner of this resource"})
				c.Abort()
				return
			}
		}

		c.Next()
	}
}
