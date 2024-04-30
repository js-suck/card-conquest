package services

import (
	"authentication-api/models"
	"gorm.io/gorm"
)

type GameService struct {
	// This service can use all the methods of genericService or can override it
	*GenericService
}

func NewGameService(db *gorm.DB) *GameService {
	return &GameService{
		GenericService: NewGenericService(db, models.Game{}),
	}
}
