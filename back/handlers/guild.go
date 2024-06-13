package handlers

import (
	"authentication-api/errors"
	"authentication-api/models"
	"authentication-api/services"
	"github.com/gin-gonic/gin"
	"net/http"
	"strconv"
)

type GuildHandler struct {
	GuildService *services.GuildService
}

// NewGuildHandler creates a new GuildHandler
func NewGuildHandler(guildService *services.GuildService) *GuildHandler {
	return &GuildHandler{
		GuildService: guildService,
	}
}

// GetAllGuilds godoc
// @Summary Get all guilds
// @Description Get all guilds.
// @Tags Guild
// @Accept json
// @Produce json
// @Success 200 {array} models.GuildRead
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /guilds [get]
func (h *GuildHandler) GetAllGuilds(c *gin.Context) {
	var guilds []models.Guild

	err := h.GuildService.GetAll(&guilds, services.FilterParams{}, "Players", "Media", "Players.Media")
	if err != nil {
		c.JSON(err.Code(), err)
		return
	}

	readableGuilds := make([]models.GuildRead, len(guilds))
	for i, guild := range guilds {
		readableGuilds[i] = guild.ToRead()
	}

	c.JSON(http.StatusOK, readableGuilds)
}

// GetGuild godoc
// @Summary Get a guild by ID
// @Description Get a guild by ID
// @Tags Guild
// @Accept json
// @Produce json
// @Param id path int true "Guild ID"
// @Success 200 {object} models.GuildRead
// @Failure 400 {object} errors.ErrorResponse
// @Failure 404 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /guilds/{id} [get]
func (h *GuildHandler) GetGuild(c *gin.Context) {
	idStr := c.Param("id")
	idInt, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	guild := models.Guild{}
	errGet := h.GuildService.Get(&guild, uint(idInt))
	if errGet != nil {
		c.JSON(errGet.Code(), errGet)
		return
	}

	c.JSON(http.StatusOK, guild.ToRead())
}

// CreateGuild godoc
// @Summary Create a guild
// @Description Create a guild
// @Tags Guild
// @Accept json
// @Produce json
// @Param payload body models.Guild true "Guild Payload"
// @Success 201 {object} models.Guild
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /guilds [post]
func (h *GuildHandler) CreateGuild(c *gin.Context) {
	var guild models.Guild

	if err := c.ShouldBindJSON(&guild); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid data", err).ToGinH())
		return
	}

	err := h.GuildService.Create(&guild)
	if err != nil {
		c.JSON(err.Code(), err)
		return
	}

	c.JSON(http.StatusCreated, guild)
}

// UpdateGuild godoc
// @Summary Update a guild
// @Description Update a guild
// @Tags Guild
// @Accept json
// @Produce json
// @Param id path int true "Guild ID"
// @Param payload body models.Guild true "Guild Payload"
// @Success 200 {object} models.Guild
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /guilds/{id} [put]
func (h *GuildHandler) UpdateGuild(c *gin.Context) {
	idStr := c.Param("id")
	idInt, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	var guild models.Guild
	if err := c.ShouldBindJSON(&guild); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid data", err).ToGinH())
		return
	}

	guild.ID = uint(idInt)
	errUpdate := h.GuildService.Update(&guild)
	if errUpdate != nil {
		c.JSON(errUpdate.Code(), err)
		return
	}

	c.JSON(http.StatusOK, guild)
}

// DeleteGuild godoc
// @Summary Delete a guild
// @Description Delete a guild
// @Tags Guild
// @Accept json
// @Produce json
// @Param id path int true "Guild ID"
// @Success 204
// @Failure 400 {object} errors.ErrorResponse
// @Failure 404 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /guilds/{id} [delete]
func (h *GuildHandler) DeleteGuild(c *gin.Context) {
	idStr := c.Param("id")
	idInt, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	errDelete := h.GuildService.Delete(uint(idInt))
	if errDelete != nil {
		c.JSON(errDelete.Code(), errDelete)
		return
	}

	c.Status(http.StatusNoContent)
}

// AddUserToGuild godoc
// @Summary Add a user to a guild
// @Description Add a user to a guild
// @Tags Guild
// @Accept json
// @Produce json
// @Param id path int true "Guild ID"
// @Param userID path int true "User ID"
// @Success 200 {object} models.Guild
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /guilds/{id}/users/{userID} [post]
func (h *GuildHandler) AddUserToGuild(c *gin.Context) {
	guildIDStr := c.Param("id")
	guildID, err := strconv.Atoi(guildIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid Guild ID", err).ToGinH())
		return
	}

	userIDStr := c.Param("userID")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid User ID", err).ToGinH())
		return
	}

	errAdd := h.GuildService.AddUserToGuild(uint(userID), uint(guildID))
	if err != nil {
		c.JSON(errAdd.Code(), err)
		return
	}

	c.Status(http.StatusOK)
}

// RemoveUserFromGuild godoc
// @Summary Remove a user from a guild
// @Description Remove a user from a guild
// @Tags Guild
// @Accept json
// @Produce json
// @Param id path int true "Guild ID"
// @Param userID path int true "User ID"
// @Success 204
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /guilds/{id}/users/{userID} [delete]
func (h *GuildHandler) RemoveUserFromGuild(c *gin.Context) {
	guildIDStr := c.Param("id")
	guildID, err := strconv.Atoi(guildIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid Guild ID", err).ToGinH())
		return
	}

	userIDStr := c.Param("userID")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid User ID", err).ToGinH())
		return
	}

	errSupp := h.GuildService.RemoveUser(uint(guildID), uint(userID))
	if err != nil {
		c.JSON(errSupp.Code(), err)
		return
	}

	c.Status(http.StatusNoContent)
}
