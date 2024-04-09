package repository

import (
	"authentication-api/models"
	"database/sql"
)

type UserRepository struct {
	*GenericRepository[models.User]
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{
		GenericRepository: NewGenericRepository[models.User](db, "users"),
	}
}
