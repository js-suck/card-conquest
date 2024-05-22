package handlers

import (
	"authentication-api/models"
	"authentication-api/services"
	"github.com/gin-gonic/gin"
	"net/http"
	"strconv"
)

type MatchHandler struct {
	MatchService *services.MatchService
}

func NewMatchHandler(matchService *services.MatchService) *MatchHandler {
	return &MatchHandler{
		MatchService: matchService,
	}
}

// GetAllMatchs godoc
// @Summary Get all matchs
// @Description Get all matchs.
// @Tags Match
// @Accept json
// @Produce json
// @Success 200
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /matchs [get]
func (h *MatchHandler) GetAllMatchs(c *gin.Context) {

	var matchs []models.Match
	filterParams := services.FilterParams{}

	err := h.MatchService.GetAll(&matchs, filterParams)

	if err != nil {
		c.JSON(err.Code(), err)
		return
	}

	c.JSON(http.StatusOK, matchs)
}

// UpdateScore godoc
// @Summary Update score
// @Description Update score.
// @Tags Match
// @Accept json
// @Produce json
// @Success 200
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /matchs/update/score [post]
func (h *MatchHandler) UpdateScore(ctx *gin.Context) {

	matchIdStr := ctx.PostForm("matchId")
	userIdStr := ctx.PostForm("userId")
	scoreStr := ctx.PostForm("score")

	matchId, err := strconv.Atoi(matchIdStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid match id"})
	}

	userId, err := strconv.Atoi(userIdStr)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user id"})
	}

	var score models.Score
	score.MatchID = uint(matchId)
	score.PlayerID = uint(userId)
	score.Score, err = strconv.Atoi(scoreStr)

	err = h.MatchService.UpdateScore(uint(matchId), &score, userId)

	ctx.JSON(http.StatusOK, gin.H{"message": "Score updated"})

}
