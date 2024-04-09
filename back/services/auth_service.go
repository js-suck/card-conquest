package services

import (
	"authentication-api/models"
	"errors"
	"gorm.io/gorm"
)

type AuthService struct {
	db *gorm.DB
}

func NewAuthService(db *gorm.DB) *AuthService {
	return &AuthService{db: db}
}

func (a AuthService) Login(user *models.User) error {
	a.db.Where("username = ? AND password = ?", user.Username, user.Password).First(&user)
	if user.ID == 0 {
		return errors.New("invalid credentials")
	}

	return nil
}

func (a AuthService) Register(username, password string) error {
	//TODO implement me
	panic("implement me")
}
