package services

import (
	"authentication-api/models"
	"gorm.io/gorm"
)

type UserService struct {
	// This service can use all the methods of genericService or can override it
	*GenericService
}

//func (u UserService) Update(m models.IModel) error {
//	//TODO implement me (if you want to override the generic service)
//	panic("implement me")
//}

func NewUserService(db *gorm.DB) *UserService {
	return &UserService{
		GenericService: NewGenericService(db, models.User{}),
	}
}

func (s UserService) GetUserStats(userId uint) (models.UserStats, error) {
	userStats := models.UserStats{}
	err := s.db.Where("user_id = ?", userId).First(&userStats).Error
	return userStats, err
}
