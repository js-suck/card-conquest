package handlers

import (
	"authentication-api/errors"
	"authentication-api/models"
	"authentication-api/services"
	"github.com/gin-gonic/gin"
	"net/http"
	"strconv"
	"strings"
)

type TournamentHandler struct {
	TounamentService *services.TournamentService
	FileService      *services.FileService
	MatchService     *services.MatchService
}

func NewTournamentHandler(tournamentService *services.TournamentService, fileService *services.FileService, matchService *services.MatchService) *TournamentHandler {
	return &TournamentHandler{TounamentService: tournamentService, FileService: fileService, MatchService: matchService}
}

func (h *TournamentHandler) parseFilterParams(c *gin.Context) services.FilterParams {
	TournamentID := c.Query("TournamentID")
	UserID := c.Query("UserID")
	GameID := c.Query("GameID")
	Sort := c.Query("Sort")
	Name := c.Query("Name")

	filterParams := services.FilterParams{
		Fields: map[string]interface{}{},
		Sort:   []string{},
	}

	if TournamentID != "" {
		filterParams.Fields["TournamentID"] = TournamentID

	}

	if UserID != "" {
		filterParams.Fields["UserID"] = UserID

	}

	if GameID != "" {
		filterParams.Fields["GameID"] = GameID
	}

	if Name != "" {
		filterParams.Fields["Name"] = Name
	}

	if Sort != "" {
		filterParams.Sort = strings.Split(Sort, ",")
	}

	return filterParams
}

// CreateTournament godoc
// @Summary Create a new tournament
// @Description Create a new tournament
// @Tags tournament
// @Accept mpfd
// @Produce json
// @Param name formData string true "Tournament name" Example("My Tournament")
// @Param description formData string true "Tournament description" Example("Description of my tournament")
// @Param start_date formData string true "Tournament start date" Example("2024-04-12T00:00:00Z")
// @Param end_date formData string true "Tournament end date" Example("2024-04-15T00:00:00Z")
// @Param organizer_id formData int true "Organizer ID" Example(1)
// @Param game_id formData int true "Game ID" Example(1)
// @Param rounds formData int true "Number of rounds" Example(3)
// @Param tagsIDs[] formData []int true "Array of tag IDs" CollectionFormat(multi) Example([1, 2, 3])
// @Param image formData file true "Image file" Example(<path_to_image_file>)
// @Param location formData string true "Location" Example("New York")
// @Param max_players formData int true "Maximum number of players" Example(32)
// @Param longitude formData float64 true "Longitude" Example(40.7128)
// @Param latitude formData float64 true "Latitude" Example(74.0060)
// @Success 200 {object} models.Tournament
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments [post]
func (h *TournamentHandler) CreateTournament(c *gin.Context) {
	file, err := c.FormFile("image")
	if err != nil {
		if errors.IsFileNotFound(err) {
			file = nil
		} else {
			c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Something went wrong with the file", err).ToGinH())
			return
		}
	}
	tagsIDsStr := c.PostFormArray("tagsIDs[]")
	var tagsIDs []uint

	for _, idStr := range tagsIDsStr {
		id, err := strconv.ParseUint(idStr, 10, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid tag ID", err).ToGinH())
			return
		}
		tagsIDs = append(tagsIDs, uint(id))
	}

	var payload models.CreateTournamentPayload

	if err := c.ShouldBind(&payload); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", err).ToGinH())
		return
	}

	tournament := models.Tournament{
		Name:        payload.Name,
		Description: payload.Description,
		StartDate:   payload.StartDate,
		EndDate:     payload.EndDate,
		Location:    payload.Location,
		UserID:      payload.UserID,
		GameID:      payload.GameID,
		Rounds:      payload.Rounds,
		Longitude:   payload.Longitude,
		Latitude:    payload.Latitude,
		MaxPlayers:  payload.MaxPlayers,
	}

	if file != nil {
		// Upload de l'image
		mediaModel, _, errUpload := h.FileService.UploadMedia(file)
		if errUpload != nil {
			c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", errUpload).ToGinH())
			return
		}
		tournament.MediaModel.Media = mediaModel

	}

	tags, err := h.TounamentService.GetTagsByIDs(tagsIDs)
	if err != nil {
		c.JSON(http.StatusInternalServerError, errors.NewErrorResponse(500, err.Error()).ToGinH())
		return
	}
	tournament.Tags = tags

	errorCreated := h.TounamentService.CreateTournament(&tournament)
	if errorCreated != nil {
		c.JSON(errorCreated.Code(), errorCreated.Error())
		return
	}

	c.JSON(http.StatusOK, "Tournament created successfully")
}

// GetTournament godoc
// @Summary Get a tournament
// @Description Get a tournament
// @Tags tournament
// @Accept json
// @Produce json
// @Param id path int true "Tournament ID"
// @Success 200 {object} models.Tournament
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments/{id} [get]
func (h *TournamentHandler) GetTournament(c *gin.Context) {
	idStr := c.Param("id")
	idInt, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	tournament := models.Tournament{}

	errService := h.TounamentService.Get(&tournament, uint(idInt), "User", "Game", "Media", "Users")

	if err != nil {
		c.JSON(errService.Code(), err)
		return
	}

	c.JSON(http.StatusOK, tournament.ToRead())

}

type TournamentsParams struct {
	WithRecents bool `form:"WithRecents"`
}

// GetTournaments godoc
// @Summary Get all tournaments
// @Description Get all tournaments
// @Tags tournament
// @Accept json
// @Produce json
// @Param WithRecents query bool false "Add recent tournaments to the response"
// @Param UserID query int 0 "Search by userID"
// @Param GameID query int 0 "Search by gameID"
// @Param Name query string false "Search by name"
// @Param Sort query string false "Sort order (use 'start_date' for ascending order, '-start_date' for descending order)"// @Success 200 {object} string
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments [get]
func (h *TournamentHandler) GetTournaments(c *gin.Context) {
	var tournaments []models.Tournament
	var recentTournaments []models.Tournament
	var formattedTournaments []models.TournamentRead
	var tournamentsParams TournamentsParams

	if err := c.ShouldBindQuery(&tournamentsParams); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", err).ToGinH())
		return
	}

	filterParams := h.parseFilterParams(c)

	err := h.TounamentService.GetAll(&tournaments, filterParams, "User", "Game", "Media", "Users")

	// use toRead method to convert the model to the read model
	for i, tournament := range tournaments {
		formattedTournaments = append(formattedTournaments, tournament.ToRead())
		tournaments[i] = tournament
	}

	if err != nil {
		c.JSON(err.Code(), err)
		return
	}

	if tournamentsParams.WithRecents {
		err = h.TounamentService.GetRecentsTournaments(&recentTournaments)

		if err != nil {
			c.JSON(err.Code(), err)
			return
		}

		for i, tournament := range recentTournaments {
			formattedTournaments = append(formattedTournaments, tournament.ToRead())
			recentTournaments[i] = tournament
		}

		c.JSON(http.StatusOK, gin.H{
			"allTournaments":    formattedTournaments,
			"recentTournaments": recentTournaments,
		})

	} else {

		c.JSON(http.StatusOK, formattedTournaments)
	}
}

// RegisterUser godoc
// @Summary Register a user to a tournament
// @Description Register a user to a tournament
// @Tags tournament
// @Accept json
// @Produce json
// @Param id path int true "Tournament ID"
// @Param userID path int true "User ID"
// @Param Status query string false "Status" Example(s) : "opened"
// @Success 200 {object} string
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments/{id}/register/{userID} [post]
func (h *TournamentHandler) RegisterUser(context *gin.Context) {
	tournamentID, err := strconv.Atoi(context.Param("id"))
	if err != nil {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	userID, err := strconv.Atoi(context.Param("userID"))
	if err != nil {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	errService := h.TounamentService.RegisterUser(uint(tournamentID), uint(userID))
	if errService != nil {
		context.JSON(errService.Code(), errService)
		return
	}

	context.JSON(http.StatusOK, "User registered successfully")

}

// GenerateMatches godoc
// @Summary Generate matches for a tournament
// @Description Generate matches for a tournament
// @Tags tournament
// @Accept json
// @Produce json
// @Param id path int true "Tournament ID"
// @Success 200 {object} string
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments/{id}/generate-matches [POST]
func (h *TournamentHandler) GenerateMatches(context *gin.Context) {
	tournamentID, err := strconv.Atoi(context.Param("id"))
	if err != nil {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	errService := h.MatchService.GenerateMatches(uint(tournamentID))
	if errService != nil {
		context.JSON(errService.Code(), errService)
		return
	}

	context.JSON(http.StatusOK, "Matches generated successfully")
}

//// FinishMatch godoc
//// @Summary Finish a match
//// @Description Finish a match
//// @Tags tournament
//// @Accept json
//// @Produce json
//// @Param id path int true "Match ID"
//// @Param winnerId query int true "Winner ID"
//// @Success 200 {object} string
//// @Failure 400 {object} errors.ErrorResponse
//// @Failure 500 {object} errors.ErrorResponse
//// @Security BearerAuth
//// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
//// @Router /matches/{id}/finish [post]
//func (h *TournamentHandler) FinishMatch(context *gin.Context) {
//	matchID, err := strconv.Atoi(context.Param("id"))
//	winnerId, err := strconv.Atoi(context.Query("winnerId"))
//	if err != nil {
//		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
//		return
//	}
//
//	errService := h.TounamentService.FinishMatch(uint(matchID), uint(winnerId))
//	if errService != nil {
//		context.JSON(errService.Code(), errService)
//		return
//	}
//
//	context.JSON(http.StatusOK, "Match finished successfully")
//}

// StartTournament godoc
// @Summary Start a tournament
// @Description Start a tournament
// @Tags tournament
// @Accept json
// @Produce json
// @Param id path int true "Tournament ID"
// @Success 200 {object} string
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth ini
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments/{id}/start [post]
func (h *TournamentHandler) StartTournament(context *gin.Context) {
	tournamentID, err := strconv.Atoi(context.Param("id"))
	if err != nil {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	errService := h.TounamentService.StartTournament(uint(tournamentID))
	if errService != nil {
		context.JSON(errService.Code(), errService)
		return
	}

	context.JSON(http.StatusOK, "Tournament started successfully")
}

// GetTournamentMatches godoc
// @Summary Get all matches of a tournament
// @Description Get all matches of a tournament
// @Tags tournament
// @Accept json
// @Produce json
// @Param id path int true "Tournament ID"
// @Success 200 {object} string
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments/{id}/matches [get]
func (h *TournamentHandler) GetTournamentMatches(context *gin.Context) {
	tournamentID, err := strconv.Atoi(context.Param("id"))
	if err != nil {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	matches, errService := h.MatchService.GetTournamentMatches(uint(tournamentID))
	if errService != nil {
		context.JSON(errService.Code(), errService)
		return
	}

	context.JSON(http.StatusOK, matches)
}

// GetTournamentRankings godoc
// @Summary Get the ranking of a tournament
// @Description Get the ranking of a tournament
// @Tags tournament
// @Accept json
// @Produce json
// @Param TournamentID query int false "Tournament ID"
// @Param UserID query int false "User ID"
// @Success 200 {object} string
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments/rankings [get]
func (h *TournamentHandler) GetTournamentRankings(c *gin.Context) {

	if c.Query("TournamentID") != "" || c.Query("UserID") != "" {

		filterParams := h.parseFilterParams(c)

		ranking, errService := h.TounamentService.CalculateRanking(&filterParams)
		if errService != nil {
			c.JSON(errService.Code(), errService)
			return
		}
		c.JSON(http.StatusOK, ranking)
		return

	}

	ranking, errService := h.TounamentService.GetGlobalRankings()
	if errService != nil {
		c.JSON(errService.Code(), errService)
		return
	}

	c.JSON(http.StatusOK, ranking)
}

// ... other code ...

// UpdateTournament godoc
// @Summary Update a tournament
// @Description Update a tournament
// @Tags tournament
// @Accept json
// @Produce json
// @Param id path int true "Tournament ID"
// @Param name formData string false "Tournament name" Example("My Tournament")
// @Param description formData string false "Tournament description" Example("Description of my tournament")
// @Param start_date formData string false "Tournament start date" Example("2024-04-12T00:00:00Z")
// @Param end_date formData string false "Tournament end date" Example("2024-04-15T00:00:00Z")
// @Param organizer_id formData int false "Organizer ID" Example(1)
// @Param game_id formData int false "Game ID" Example(1)
// @Param rounds formData int false "Number of rounds" Example(3)
// @Param tagsIDs[] formData []int false "Array of tag IDs" CollectionFormat(multi) Example([1, 2, 3])
// @Param image formData file false "Image file" Example(<path_to_image_file>)
// @Param location formData string false "Location" Example("New York")
// @Param max_players formData int false "Maximum number of players" Example(32)
// @Param longitude formData float64 false "Longitude" Example(40.7128)
// @Param latitude formData float64 false "Latitude" Example(74.0060)
// @Success 200 {object} string
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments/{id} [put]
func (h *TournamentHandler) UpdateTournament(c *gin.Context) {
	tournamentID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	file, err := c.FormFile("image")
	if err != nil {
		if errors.IsFileNotFound(err) {
			file = nil
		} else {
			c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Something went wrong with the file", err).ToGinH())
			return
		}
	}

	tagsIDsStr := c.PostFormArray("tagsIDs[]")
	var tagsIDs []uint

	for _, idStr := range tagsIDsStr {
		id, err := strconv.ParseUint(idStr, 10, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid tag ID", err).ToGinH())
			return
		}
		tagsIDs = append(tagsIDs, uint(id))
	}

	var payload models.UpdateTournamentPayload

	if err := c.ShouldBind(&payload); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", err).ToGinH())
		return
	}

	tournament := models.Tournament{
		ID:          uint(tournamentID),
		Name:        payload.Name,
		Description: payload.Description,
		StartDate:   payload.StartDate,
		EndDate:     payload.EndDate,
		Location:    payload.Location,
		UserID:      payload.UserID,
		GameID:      payload.GameID,
		Rounds:      payload.Rounds,
		Longitude:   payload.Longitude,
		Latitude:    payload.Latitude,
		MaxPlayers:  payload.MaxPlayers,
	}

	tags, err := h.TounamentService.GetTagsByIDs(tagsIDs)
	if err != nil {
		c.JSON(http.StatusInternalServerError, errors.NewErrorResponse(500, err.Error()).ToGinH())
		return
	}
	tournament.Tags = tags

	if file != nil {
		mediaModel, _, errUpload := h.FileService.UploadMedia(file)
		if errUpload != nil {
			c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", errUpload).ToGinH())
			return
		}
		tournament.MediaModel.Media = mediaModel
	}

	errorUpdated := h.TounamentService.Update(&tournament)
	if errorUpdated != nil {
		c.JSON(errorUpdated.Code(), errorUpdated.Error())
		return
	}

	c.JSON(http.StatusOK, "Tournament updated successfully")
}

// DeleteTournament godoc
// @Summary Delete a tournament
// @Description Delete a tournament
// @Tags tournament
// @Accept json
// @Produce json
// @Param id path int true "Tournament ID"
// @Success 204
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments/{id} [delete]
func (h *TournamentHandler) DeleteTournament(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid tournament ID", err).ToGinH())
		return
	}

	if err := h.TounamentService.Delete(uint(id)); err != nil {
		c.JSON(err.Code(), err)
		return
	}

	c.Status(http.StatusNoContent)
}
