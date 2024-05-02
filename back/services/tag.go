package services

import (
	"authentication-api/models"
	"gorm.io/gorm"
)

type TagService struct {
	*GenericService
}

func NewTagService(db *gorm.DB) *TagService {
	return &TagService{
		GenericService: NewGenericService(db, models.Tag{}),
	}
}
