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
	if err := s.Db.Preload("Players").First(&guild, guildID).Error; err != nil {
		return errors.NewInternalServerError("Guild not found", err)
	}
	if err := s.Db.First(&user, userID).Error; err != nil {
		return errors.NewInternalServerError("User not found", err)
	}
	fmt.Printf("Guild: %+v\n", guild)
	fmt.Printf("User: %+v\n", user)
	err := s.Db.Model(&guild).Association("Players").Append(&user)
	if err != nil {
		return errors.NewInternalServerError("Could not add user to guild", err)
	}
	return nil
}

func (s GuildService) AddAdminToTheGuild(guildID uint, userID uint) errors.IError {
	guild := models.Guild{}
	user := models.User{}
	if err := s.Db.Preload("Admins").First(&guild, guildID).Error; err != nil {
		return errors.NewInternalServerError("Guild not found", err)
	}
	if err := s.Db.First(&user, userID).Error; err != nil {
		return errors.NewInternalServerError("User not found", err)
	}
	err := s.Db.Model(&guild).Association("Admins").Append(&user)
	if err != nil {
		return errors.NewInternalServerError("Could not add user to guild", err)
	}
	return nil
}

func (s GuildService) RemoveUser(u uint, u2 uint) errors.IError {

	guild := models.Guild{}
	user := models.User{}
	if err := s.Db.Preload("Players").First(&guild, u).Error; err != nil {
		return errors.NewInternalServerError("Guild not found", err)
	}
	if err := s.Db.First(&user, u2).Error; err != nil {
		return errors.NewInternalServerError("User not found", err)
	}
	err := s.Db.Model(&guild).Association("Players").Delete(&user)
	if err != nil {
		return errors.NewInternalServerError("Could not remove user from guild", err)
	}
	return nil
}

func (s *GuildService) GetGuildsByUserId(userId uint, guilds *[]models.Guild) errors.IError {
	query := s.Db.Where("id IN (?)", s.Db.Table("guild_players").Select("guild_id").Where("user_id = ?", userId))

	if err := query.Find(guilds).Error; err != nil {
		return errors.NewInternalServerError("Error getting guilds", err)
	}

	return nil
}
