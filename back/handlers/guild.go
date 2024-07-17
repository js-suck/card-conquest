package handlers

import (
	"authentication-api/errors"
	"authentication-api/firebase"
	"authentication-api/middlewares"
	"authentication-api/models"
	"authentication-api/services"
	"fmt"
	"github.com/gin-gonic/gin"
	"log"
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
	errGet := h.GuildService.Get(&guild, uint(idInt), "Players", "Media", "Players.Media", "Admins", "Admins.Media")
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
	userId, _ := c.Get("user_id")

	if err := c.ShouldBindJSON(&guild); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid data", err).ToGinH())
		return
	}

	err := h.GuildService.Create(&guild)

	errAdd := h.GuildService.AddAdminToTheGuild(guild.ID, uint(userId.(float64)))

	if errAdd != nil {
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

	admin := models.User{}
	userService := services.NewUserService(h.GuildService.Db)
	errGet := userService.Get(&admin, uint(userID))

	if errGet != nil {
		c.JSON(errGet.Code(), errGet)
		return
	}

	firebaseClient, errF := firebase.NewFirebaseClient("./firebase/privateKey.json")
	if errF != nil {
		log.Fatalf("Failed to initialize Firebase: %v", errF)
	}

	token := admin.FCMToken
	title := "New player joined your guild"
	body := "A new player has joined your guild"
	response, err := firebaseClient.SendNotification(token, title, body)
	if err != nil {
		log.Printf("Failed to send notification: %v", err)
	}
	fmt.Printf("Successfully sent notification: %s\n", response)

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
	user, errUserCtx := middlewares.GetCurrentUserFromContext(c)

	if errUserCtx != nil {
		c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "forbidden"})
		return
	}

	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid User ID", err).ToGinH())
		return
	}

	if !user.IsAdmin() {
		errRemove := h.GuildService.CanDeleteUserFromGuild(uint(guildID), user.ID, uint(userID))

		if errRemove != nil {
			c.JSON(errRemove.Code(), errRemove)
			return
		}
	}

	errSupp := h.GuildService.RemoveUser(uint(guildID), uint(userID))
	if err != nil {
		c.JSON(errSupp.Code(), err)
		return
	}

	c.Status(http.StatusNoContent)
}

// GetGuildsByUserId godoc
// @Summary Get guilds by user ID
// @Description Get guilds by user ID
// @Tags Guild
// @Accept json
// @Produce json
// @Param userId path int true "User ID"
// @Success 200 {array} models.GuildRead
// @Failure 400 {object} errors.ErrorResponse
// @Failure 404 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /guilds/user/{userId} [get]
func (h *GuildHandler) GetGuildsByUserId(c *gin.Context) {
	userIdStr := c.Param("userId")
	userId, err := strconv.Atoi(userIdStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid user ID", err).ToGinH())
		return
	}

	var guilds []models.Guild
	errG := h.GuildService.GetGuildsByUserId(uint(userId), &guilds)
	if errG != nil {
		c.JSON(errG.Code(), err)
		return
	}

	readableGuilds := make([]models.GuildRead, len(guilds))
	for i, guild := range guilds {
		readableGuilds[i] = guild.ToRead()
	}

	c.JSON(http.StatusOK, readableGuilds)
}
