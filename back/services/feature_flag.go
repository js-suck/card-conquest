package services

import (
	"authentication-api/models"
	"gorm.io/gorm"
)

type FeatureFlagService struct {
	db *gorm.DB
}

func NewFeatureFlagService(db *gorm.DB) *FeatureFlagService {
	return &FeatureFlagService{
		db: db,
	}
}

func (s *FeatureFlagService) GetFeatureFlag(name string) (bool, error) {
	var featureFlag models.FeatureFlag
	result := s.db.Where("name = ?", name).First(&featureFlag)
	if result.Error != nil {
		return false, result.Error
	}
	return featureFlag.Enabled, nil
}

func (s *FeatureFlagService) SetFeatureFlag(name string, enabled bool) error {
	featureFlag := models.FeatureFlag{
		Name:    name,
		Enabled: enabled,
	}
	result := s.db.Create(&featureFlag)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (s *FeatureFlagService) GetFeatureFlags() (interface{}, interface{}) {
	var featureFlags []models.FeatureFlag
	result := s.db.Find(&featureFlags)
	if result.Error != nil {
		return nil, result.Error
	}
	return featureFlags, nil
}
