package handlers

import (
	"authentication-api/models"
	"authentication-api/services"
	"github.com/gin-gonic/gin"
)

type GameHandler struct {
	GameService *services.GameService
}

func NewGameHandler(gameService *services.GameService) *GameHandler {
	return &GameHandler{
		GameService: gameService,
	}
}

// GetAllGames godoc
// @Summary Get all games
// @Description Get all games
// @Tags Game
// @Accept json
// @Produce json
// @Success 200 {object} string
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /games [get]
func (h *GameHandler) GetAllGames(c *gin.Context) {
	var games []models.Game
	var filterParams services.FilterParams

	err := h.GameService.GetAll(&games, filterParams)

	if err != nil {
		c.JSON(err.Code(), err)
		return

	}

	c.JSON(200, games)
}
