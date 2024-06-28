package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	"fmt"
	"gorm.io/gorm"
)

type GuildService struct {
	*GenericService
}

func NewGuildService(db *gorm.DB) *GuildService {
	return &GuildService{NewGenericService(db, &models.Guild{})}
}

func (s GuildService) AddUserToGuild(userID uint, guildID uint) errors.IError {
	guild := models.Guild{}
	user := models.User{}
	if err := s.db.Preload("Players").First(&guild, guildID).Error; err != nil {
		return errors.NewInternalServerError("Guild not found", err)
	}
	if err := s.db.First(&user, userID).Error; err != nil {
		return errors.NewInternalServerError("User not found", err)
	}
	fmt.Printf("Guild: %+v\n", guild)
	fmt.Printf("User: %+v\n", user)
	err := s.db.Model(&guild).Association("Players").Append(&user)
	if err != nil {
		return errors.NewInternalServerError("Could not add user to guild", err)
	}
	return nil
}

func (s GuildService) RemoveUser(u uint, u2 uint) errors.IError {

	guild := models.Guild{}
	user := models.User{}
	if err := s.db.Preload("Players").First(&guild, u).Error; err != nil {
		return errors.NewInternalServerError("Guild not found", err)
	}
	if err := s.db.First(&user, u2).Error; err != nil {
		return errors.NewInternalServerError("User not found", err)
	}
	err := s.db.Model(&guild).Association("Players").Delete(&user)
	if err != nil {
		return errors.NewInternalServerError("Could not remove user from guild", err)
	}
	return nil
}
