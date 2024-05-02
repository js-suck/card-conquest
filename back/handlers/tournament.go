package handlers

import (
	"authentication-api/errors"
	"authentication-api/models"
	"authentication-api/services"
	"encoding/json"
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
	"strconv"
)

type TournamentHandler struct {
	TounamentService *services.TournamentService
	FileService      *services.FileService
}

func NewTournamentHandler(tournamentService *services.TournamentService, fileService *services.FileService) *TournamentHandler {
	return &TournamentHandler{TounamentService: tournamentService, FileService: fileService}
}

// CreateTournament godoc
// @Summary Create a new tournament
// @Description Create a new tournament
// @Tags tournament
// @Accept mpfd
// @Produce json
// @Param name formData string true "Tournament name" Example(s) : "My Tournament"
// @Param description formData string true "Tournament description" Example(s) : "Description of my tournament"
// @Param start_date formData string true "Tournament start date" Example(s) : "2024-04-12T00:00:00Z"
// @Param end_date formData string true "Tournament end date" Example(s) : "2024-04-15T00:00:00Z"
// @Param organizer_id formData int true "Organizer ID" Example(s) : 1
// @Param game_id formData int true "Game ID" Example(s) : 1
// @Param rounds formData int true "Number of rounds" Example(s) : 3
// @Param tagsIDs[] formData []int true "Array of tag IDs" Example(s) : 1, 2, 3
// @Param image formData file true "Image file" Example(s) : <path_to_image_file>
// @Success 200 {object} models.Tournament
// @Failure 400
// @Failure 500
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments [post]
func (h *TournamentHandler) CreateTournament(c *gin.Context) {
	file, err := c.FormFile("image")
	tagsIDsStr := c.PostFormArray("tagsIDs")
	var tagsIDs []uint

	for _, idStr := range tagsIDsStr {
		id, err := strconv.ParseUint(idStr, 10, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid tag ID", err).ToGinH())
			return
		}
		tagsIDs = append(tagsIDs, uint(id))
	}
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Something went wrong with the file", err).ToGinH())
		return
	}

	var payload models.CreateTournamentPayload
	if err := c.ShouldBind(&payload); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", err).ToGinH())
		return
	}

	// Upload de l'image
	mediaModel, _, errUpload := h.FileService.UploadMedia(file)
	if errUpload != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", errUpload).ToGinH())
		return
	}

	// Ajouter l'image au modèle de tournoi
	tournament := models.Tournament{
		Name:        payload.Name,
		Description: payload.Description,
		StartDate:   payload.StartDate,
		EndDate:     payload.EndDate,
		Location:    payload.Location,
		UserID:      payload.UserID,
		GameID:      payload.GameID,
		Rounds:      payload.Rounds,
	}

	tournament.MediaModel.Media = mediaModel

	tags, err := h.TounamentService.GetTagsByIDs(tagsIDs)
	if err != nil {
		c.JSON(http.StatusInternalServerError, errors.NewErrorResponse(500, err.Error()).ToGinH())
		return
	}
	tournament.Tags = tags

	errorCreated := h.TounamentService.Create(&tournament)
	if errorCreated != nil {
		c.JSON(errorCreated.Code(), err)
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

	errService := h.TounamentService.Get(&tournament, uint(idInt), "User", "Game")

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
// @Success 200 {object} string
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tournaments [get]
func (h *TournamentHandler) GetTournaments(c *gin.Context) {
	var tournaments []models.Tournament
	var recentTournaments []models.Tournament
	var formattedTournaments []models.TournamentRead
	var filterParams services.FilterParams
	var tournamentsParams TournamentsParams

	if err := c.ShouldBindQuery(&tournamentsParams); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", err).ToGinH())
		return
	}

	err := h.TounamentService.GetAll(&tournaments, filterParams, "User", "Game")

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

		jsonResponse, err := json.Marshal(gin.H{
			"allTournaments":    formattedTournaments,
			"recentTournaments": recentTournaments,
		})
		if err != nil {
			log.Printf("Error marshalling JSON: %v", err)
		} else {
			log.Printf("JSON Response: %s", jsonResponse)
		}

		c.JSON(http.StatusOK, jsonResponse)

	}

	c.JSON(http.StatusOK, formattedTournaments)
}

// RegisterUser godoc
// @Summary Register a user to a tournament
// @Description Register a user to a tournament
// @Tags tournament
// @Accept json
// @Produce json
// @Param id path int true "Tournament ID"
// @Param userID path int true "User ID"
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

	errService := h.TounamentService.GenerateMatches(uint(tournamentID))
	if errService != nil {
		context.JSON(errService.Code(), errService)
		return
	}

	context.JSON(http.StatusOK, "Matches generated successfully")
}

// FinishMatch godoc
// @Summary Finish a match
// @Description Finish a match
// @Tags tournament
// @Accept json
// @Produce json
// @Param id path int true "Match ID"
// @Param winnerId query int true "Winner ID"
// @Success 200 {object} string
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /matches/{id}/finish [post]
func (h *TournamentHandler) FinishMatch(context *gin.Context) {
	matchID, err := strconv.Atoi(context.Param("id"))
	winnerId, err := strconv.Atoi(context.Query("winnerId"))
	if err != nil {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	errService := h.TounamentService.FinishMatch(uint(matchID), uint(winnerId))
	if errService != nil {
		context.JSON(errService.Code(), errService)
		return
	}

	context.JSON(http.StatusOK, "Match finished successfully")
}
