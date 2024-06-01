package handlers

import (
	"authentication-api/errors"
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

type MatchParams struct {
	userID int `form:"UserID"`
}

func (h *MatchHandler) parseFilterParams(c *gin.Context) services.FilterParams {
	UserID := c.Query("UserID")
	TournamentID := c.Query("TournamentID")
	Status := c.Query("Status")
	Unfinished := c.Query("Unfinished")

	filterParams := services.FilterParams{
		Fields: map[string]interface{}{},
		Sort:   []string{},
	}

	if UserID != "" {
		filterParams.Fields["UserID"] = UserID
	}

	if TournamentID != "" {
		filterParams.Fields["TournamentID"] = TournamentID
	}

	if Status != "" {
		filterParams.Fields["Status"] = Status

	}

	if Unfinished != "" {
		filterParams.Fields["Unfinished"] = Unfinished

	}

	return filterParams
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
// @Param UserID query int 0 "Search by userID"
// @Param Status query string 0 "Search by Status"
// @Param Unfinished query bool false "Search by Unfinished"
// @Param TournamentID query int 0 "Search by TournamentID"
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /matchs [get]
func (h *MatchHandler) GetAllMatchs(c *gin.Context) {

	var matchs []models.Match
	filterParams := h.parseFilterParams(c)
	filterParams.Sort = append(filterParams.Sort, "-start_time")

	err := h.MatchService.GetAll(&matchs, filterParams)

	if err != nil {
		c.JSON(err.Code(), err)
		return
	}

	readableMatches := make([]models.MatchRead, len(matchs))
	for i, match := range matchs {
		readableMatches[i] = match.ToRead()
	}

	c.JSON(http.StatusOK, readableMatches)
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
// @Param matchId formData string true "Match ID"
// @Param userId formData string true "User ID"
// @Param score formData string true "Score"
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

// UpdateMatch godoc
// @Summary Update a match
// @Description Update a match with the given ID.
// @Tags Match
// @Accept json
// @Produce json
// @Success 200
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Param id path string true "Match ID"
// @Param match body models.Match true "Match data"
// @Router /matchs/{id} [put]
func (h *MatchHandler) UpdateMatch(c *gin.Context) {
	matchIdStr := c.Param("id")
	matchId, err := strconv.Atoi(matchIdStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid match id"})
		return
	}

	var match models.Match
	match.ID = uint(matchId)
	if err := c.ShouldBindJSON(&match); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = h.MatchService.Update(&match)
	if err != nil {
		c.JSON(http.StatusInternalServerError, errors.NewInternalServerError("Error updating match", err).ToGinH())
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Match updated"})
}

// GetMatch godoc
// @Summary Get a match
// @Description Get a match with the given ID.
// @Tags Match
// @Accept json
// @Produce json
// @Success 200 {object} models.Match
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth®
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Param matchId path string true "Match ID"
// @Router /matchs/{matchId} [get]
func (h *MatchHandler) GetMatch(c *gin.Context) {
	idStr := c.Param("id")
	idInt, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	user := models.Match{}

	err = h.MatchService.Get(&user, uint(idInt), "PlayerOne", "PlayerTwo", "Winner", "Scores", "TournamentStep", "Tournament", "Winner")
	if err != nil {
		c.JSON(http.StatusNotFound, errors.NewNotFoundError("Match not found", err).ToGinH())
		return
	}

	c.JSON(http.StatusOK, user)
}

// GetMatchesBetweenUsers godoc
// @Summary Get matches between users
// @Description Get matches between users.
// @Tags Match
// @Accept json
// @Produce json
// @Success 200
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Param Player1ID query int true "Player1 ID"
// @Param PlayerID2 query int true "Player2 ID"
// @Router /matchs/between-users [get]
func (h *MatchHandler) GetMatchesBetweenUsers(c *gin.Context) {
	userID1, err := strconv.ParseUint(c.Query("Player1ID"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Player1ID"})
		return
	}

	userID2, err := strconv.ParseUint(c.Query("PlayerID2"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid PlayerID2"})
		return
	}

	matches, err := h.MatchService.GetMatchesBetweenUsers(uint(userID1), uint(userID2))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	matchesResponse := make([]models.MatchRead, len(matches))
	for i, match := range matches {
		matchesResponse[i] = match.ToRead()
	}

	c.JSON(http.StatusOK, matchesResponse)
}
