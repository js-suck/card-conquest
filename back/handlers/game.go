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
	TrendyGames []models.GameRead `json:"trendyGames"`
	AllGames    []models.GameRead `json:"allGames"`
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
	var gameParams services.GameParams

	if err := c.ShouldBindQuery(&gameParams); err != nil {
		c.JSON(400, gin.H{"error": "Invalid data"})
		return
	}

	trendyGames, allGames, err := h.GameService.GetAll(services.FilterParams{}, gameParams, "Media")
	if err != nil {
		c.JSON(err.Code(), err)
		return
	}

	if gameParams.WithTrendy {
		c.JSON(200, gin.H{
			"trendyGames": convertToReadable(trendyGames),
			"allGames":    convertToReadable(allGames),
		})
	} else {
		c.JSON(200, convertToReadable(allGames))
	}
}

func convertToReadable(games []models.Game) []models.GameRead {
	readableGames := make([]models.GameRead, len(games))
	for i, game := range games {
		readableGames[i] = game.ToRead()
	}
	return readableGames
}

// GetUserGameRankings godoc
// @Summary Get the ranking of a user for all games
// @Description Get the ranking of a user for all games
// @Tags Game
// @Accept json
// @Produce json
// @Param UserID path int false "User ID"
// @Success 200 {object} string
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /games/{userID}/rankings [get]
func (h *GameHandler) GetUserGameRankings(c *gin.Context) {
	userID := c.Param("userID")
	if userID == "" {
		c.JSON(400, gin.H{"error": "Invalid data"})
		return
	}

	rankings, err := h.GameService.CalculateUserRankings(userID)
	if err != nil {
		c.JSON(err.Code(), err)
		return
	}

	c.JSON(200, rankings)
}
