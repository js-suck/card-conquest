package permissions

type Permission struct {
	Key       string
	CanAccess bool
}

const (
	PermissionCreateUser = "create_user"
	PermissionDeleteUser = "delete_user"
)

func CanAccess(permissions []Permission, key string) bool {
	for _, permission := range permissions {
		if permission.Key == key && permission.CanAccess {
			return true
		}
	}

	return false
}
