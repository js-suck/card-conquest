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

type GameWithTrendy struct {
	TrendyGames []models.Game `json:"trendyGames"`
	AllGames    []models.Game `json:"allGames"`
}

// GetAllGames godoc
// @Summary Get all games
// @Description Get all games. If the 'WithTrendy' query parameter is true, the response will be a 'GameWithTrendy' object. Otherwise, the response will be an array of 'models.Game'.
// @Param WithTrendy query bool false "Add trendy games to the response"
// @Tags Game
// @Accept json
// @Produce json
// @Success 200 {object} GameWithTrendy
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /games [get]
func (h *GameHandler) GetAllGames(c *gin.Context) {
	var filterParams services.FilterParams
	var gameParams services.GameParams

	if err := c.ShouldBindQuery(&gameParams); err != nil {
		c.JSON(400, gin.H{"error": "Invalid data"})
		return

	}

	trendyGames, allGames, err := h.GameService.GetAll(filterParams, gameParams)

	if err != nil {
		c.JSON(err.Code(), err)
		return
	}

	if gameParams.WithTrendy {
		c.JSON(200, gin.H{
			"trendyGames": trendyGames,
			"allGames":    allGames,
		})
		return
	} else {
		c.JSON(200, allGames)
		return
	}
}
