package services

import (
	"authentication-api/models"
	"gorm.io/gorm"
)

type GuildService struct {
	*GenericService
}

func NewGuildService(db *gorm.DB) *GuildService {
	return &GuildService{NewGenericService(db, &models.Guild{})}
}
