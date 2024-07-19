package handlers

import (
	"authentication-api/models"
	"authentication-api/services"
	"net/http"
	"strconv"

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

	allGames, trendyGames, err := h.GameService.GetAll(services.FilterParams{}, gameParams, "Media")
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
// @Router /games/user/{UserID}/rankings [get]
func (h *GameHandler) GetUserGameRankings(c *gin.Context) {
	userID := c.Param("userID")
	if userID == "" {
		c.JSON(400, gin.H{"error": "Invalid data"})
		return
	}

	rankings, err := h.GameService.CalculateUserRankingsForGames(userID)
	if err != nil {
		c.JSON(err.Code(), err)
		return
	}

	c.JSON(200, rankings)
}

// CreateGame godoc
// @Summary Create a new game
// @Description Create a new game
// @Tags Game
// @Accept json
// @Produce json
// @Param game body models.Game true "Game object"
// @Success 201 {object} models.Game
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Router /games [post]
func (h *GameHandler) CreateGame(c *gin.Context) {
	var game models.Game
	if err := c.ShouldBindJSON(&game); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid data"})
		return
	}

	if err := h.GameService.CreateGame(&game); err != nil {
		c.JSON(err.Code(), err)
		return
	}

	c.JSON(http.StatusCreated, game)
}

// UpdateGame godoc
// @Summary Update an existing game
// @Description Update an existing game
// @Tags Game
// @Accept json
// @Produce json
// @Param id path int true "Game ID"
// @Param game body models.Game true "Game object"
// @Success 200 {object} models.Game
// @Failure 400 {object} errors.ErrorResponse
// @Failure 404 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Router /games/{id} [put]
func (h *GameHandler) UpdateGame(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid game ID"})
		return
	}

	var game models.Game
	if err := c.ShouldBindJSON(&game); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid data"})
		return
	}

	if err := h.GameService.UpdateGame(uint(id), &game); err != nil {
		c.JSON(err.Code(), err)
		return
	}

	c.JSON(http.StatusOK, game)
}

// DeleteGame godoc
// @Summary Delete a game
// @Description Delete a game
// @Tags Game
// @Accept json
// @Produce json
// @Param id path int true "Game ID"
// @Success 204
// @Failure 400 {object} errors.ErrorResponse
// @Failure 404 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Router /games/{id} [delete]
func (h *GameHandler) DeleteGame(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid game ID"})
		return
	}

	if err := h.GameService.DeleteGame(uint(id)); err != nil {
		c.JSON(err.Code(), err)
		return
	}

	c.Status(http.StatusNoContent)
}

// GetGameByID godoc
// @Summary Get a game by ID
// @Description Get a game by ID
// @Tags Game
// @Accept json
// @Produce json
// @Param id path int true "Game ID"
// @Success 200 {object} models.Game
// @Failure 400 {object} errors.ErrorResponse
// @Failure 404 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /games/{id} [get]
func (h *GameHandler) GetGameByID(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid game ID"})
		return
	}

	game, errGame := h.GameService.GetGameByID(uint(id))
	if errGame != nil {
		c.JSON(errGame.Code(), err)
		return
	}

	c.JSON(http.StatusOK, game.ToRead())
}

// GetGameRanks
// @Summary Get the ranking of users for a game
// @Description Get the ranking of users for a game
// @Tags Game
// @Accept json
// @Produce json
// @Param id path int true "Game ID"
// @Success 200 {object} string
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /games/{id}/ranks [get]
func (h *GameHandler) GetGameRanks(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid game ID"})
		return
	}

	ranks, errGetRanks := h.GameService.CalculateRankingsForGame(uint(id))
	if err != nil {
		c.JSON(errGetRanks.Code(), err)
		return
	}

	c.JSON(http.StatusOK, ranks)
}
