package services

import (
	"authentication-api/errors"
	"authentication-api/firebase"
	"authentication-api/models"
	authentication_api "authentication-api/pb/github.com/lailacha/authentication-api"
	"fmt"
	"github.com/go-playground/validator/v10"
	_ "github.com/go-playground/validator/v10"
	"gorm.io/gorm"
	"math/rand"
	"sort"
	"strconv"
	"strings"
	"time"
)

type TournamentService struct {
	// This service can use all the methods of genericService or can override it
	*GenericService
}

func NewTournamentService(db *gorm.DB) *TournamentService {
	return &TournamentService{
		GenericService: NewGenericService(db, models.Tournament{}),
	}
}

var TournamentUpdates = make(chan *authentication_api.TournamentResponse, 100)

func (s TournamentService) RegisterUser(tournamentId uint, userId uint) errors.IError {
	tournament := models.Tournament{}
	user := models.User{}

	if err := s.Db.First(&tournament, tournamentId).Error; err != nil {
		return errors.NewNotFoundError("Tournament not found", err)
	}

	if err := s.Db.First(&user, userId).Error; err != nil {
		return errors.NewNotFoundError("User not found", err)
	}

	tournament.Users = append(tournament.Users, &user)

	if err := s.Db.Save(&tournament).Error; err != nil {
		return errors.NewInternalServerError("Failed to register user to tournament", err)
	}

	return nil
}

//func (s TournamentService) FinishMatch(matchID uint, winnderID uint) errors.IError {
//	match := models.Match{}
//	matchService := NewMatchService(s.db)
//
//	if err := s.db.First(&match, matchID).Error; err != nil {
//		return errors.NewNotFoundError("Match not found", err)
//	}
//
//	match.Status = "finished"
//	match.WinnerID = &winnderID
//
//	if err := s.db.Save(&match).Error; err != nil {
//		return errors.NewInternalServerError("Failed to finish match", err)
//	}
//
//	// search if there is other match without finished status
//	pendingMatchs := []models.Match{}
//	s.db.Find(&pendingMatchs, "tournament_id = ? AND status = ? AND tournament_step_id = ?", match.TournamentID, "started", match.TournamentStepID)
//
//	// search the last match and its tournament
//	s.db.Last(&match, "tournament_id = ?", match.TournamentID)
//
//	// search how many users have finished the last step
//	lastStep := models.TournamentStep{}
//	s.db.First(&lastStep, "tournament_id = ?", match.TournamentID)
//
//	// search if there is more than one match in the last step
//
//	var lastMatchCount int64
//	s.db.Model(&models.Match{}).Where("tournament_id = ? AND tournament_step_id = ?", match.TournamentID, lastStep.ID).Count(&lastMatchCount)
//
//	// if there is only one match, the winner of the match is the winner of the tournament
//
//	if lastMatchCount == 1 {
//		match.WinnerID = &match.PlayerOneID
//		match.Status = "finished"
//		s.db.Save(&match)
//		tournament := models.Tournament{}
//		s.db.First(&tournament, match.TournamentID)
//		tournament.Status = "finished"
//		s.db.Save(&tournament)
//		return nil
//	}
//
//	fmt.Println("pendingMatchs", pendingMatchs, len(pendingMatchs))
//	// if there is more than one match, check if all matches are finished
//	if len(pendingMatchs) == 0 {
//		// get all matches in the last step
//		matches := []models.Match{}
//		s.db.Find(&matches, "tournament_id = ? AND tournament_step_id = ?", match.TournamentID, lastStep.ID)
//
//		// get all winners in the last step
//		winners := []models.User{}
//		for _, match := range matches {
//			winner := models.User{}
//			s.db.First(&winner, match.WinnerID)
//			winners = append(winners, winner)
//		}
//
//		// if all winners are different, generate the next step
//		if len(winners) == len(matches) {
//			return matchService.GenerateMatches(match.TournamentID)
//		}
//	}
//
//	return nil
//
//}

// GetRecentsTournaments godoc
func (s TournamentService) GetRecentsTournaments(tournaments *[]models.Tournament) errors.IError {
	db := s.Db.Preload("User")
	db = db.Preload("Media")
	err := db.Order("start_date desc").Limit(8).Find(&tournaments).Error
	if err != nil {
		return errors.NewErrorResponse(500, err.Error())
	}
	return nil
}

func (s *TournamentService) GetTagsByIDs(tagIDs []uint) ([]*models.Tag, errors.IError) {
	var tags []*models.Tag
	for _, tagID := range tagIDs {
		var tag models.Tag
		result := s.Db.First(&tag, tagID)
		if result.Error != nil {
			return nil, errors.NewErrorResponse(400, "Tag not found with TagID: "+strconv.Itoa(int(tagID)))
		}
		tags = append(tags, &tag)
	}
	return tags, nil
}

func (s *TournamentService) CreateTournament(t *models.Tournament) errors.IError {

	if err := validate.Struct(t); err != nil {
		if _, ok := err.(*validator.InvalidValidationError); ok {
			return errors.NewValidationError("Invalid validation error", "")
		}

		for _, err := range err.(validator.ValidationErrors) {
			errorMessage := fmt.Sprintf("Error in field: %s, Condition failed: %s", err.Field(), err.ActualTag())
			return errors.NewValidationError(errorMessage, err.Field())
		}

	}

	result := s.Db.Create(t)
	if result.Error != nil {
		return errors.NewErrorResponse(500, result.Error.Error())
	}

	firtstTournamentStep := models.TournamentStep{
		TournamentID: t.ID,
		Name:         "FirstStep",
		Sequence:     1,
	}

	result = s.Db.Create(&firtstTournamentStep)
	if result.Error != nil {
		return errors.NewErrorResponse(500, result.Error.Error())
	}

	return nil
}

func (s *TournamentService) SendTournamentUpdatesForGRPC(tournamentId uint) errors.IError {
	tournament := models.Tournament{}
	tournamentResponse := authentication_api.TournamentResponse{}

	err := s.Db.Preload("Users").Preload("Steps").First(&tournament, tournamentId).Error
	if err != nil {
		return errors.NewErrorResponse(500, err.Error())
	}

	tournamentResponse.TournamentId = int32(tournament.ID)
	tournamentResponse.TournamentName = tournament.Name
	tournamentResponse.TournamentStatus = string(tournament.Status)
	tournamentResponse.TournamentSteps = []*authentication_api.TournamentStep{}

	for _, step := range tournament.Steps {
		// get les matchs
		matches := []models.Match{}
		err := s.Db.Preload("PlayerOne").Preload("Scores").Preload("PlayerTwo").Preload("Winner").Where("tournament_step_id = ?", step.ID).Find(&matches).Error

		if err != nil {
			return errors.NewErrorResponse(500, err.Error())
		}

		tournamentStep := &authentication_api.TournamentStep{
			Step:    int32(step.Sequence),
			Matches: []*authentication_api.Match{},
		}

		for _, match := range matches {
			var playerOneScore, playerTwoScore int
			for _, score := range match.Scores {
				if score.PlayerID == match.PlayerOneID {
					playerOneScore = score.Score
				} else if match.PlayerTwoID != nil && score.PlayerID == *match.PlayerTwoID {
					playerTwoScore = score.Score
				}
			}
			playerOne := &authentication_api.Player{
				UserId: strconv.Itoa(int(match.PlayerOneID)),
				Score:  int32(playerOneScore),
			}
			if match.PlayerOne.Username != "" {
				playerOne.Username = match.PlayerOne.Username
			}

			playerTwo := &authentication_api.Player{
				Score: int32(playerTwoScore),
			}
			if match.PlayerTwo.Username != "" {
				playerTwo.Username = match.PlayerTwo.Username
				playerTwo.UserId = strconv.Itoa(int(*match.PlayerTwoID))
			}

			var winnerId int32
			if match.WinnerID != nil {
				winnerId = int32(*match.WinnerID)
			}
			var startTime string
			if match.StartTime.Format(time.RFC3339) != "" {
				startTime = match.StartTime.Format(time.RFC3339)
			}
			var location string
			if match.Location != "" {
				location = match.Location
			}
			tournamentMatch := &authentication_api.Match{
				Position:  int32(match.MatchPosition),
				PlayerOne: playerOne,
				PlayerTwo: playerTwo,
				Status:    match.Status,
				WinnerId:  winnerId,
				MatchId:   int32(match.ID),
				StartTime: startTime,
				Location:  location,
			}

			tournamentStep.Matches = append(tournamentStep.Matches, tournamentMatch)
		}
		tournamentResponse.TournamentSteps = append(tournamentResponse.TournamentSteps, tournamentStep)
	}

	TournamentUpdates <- &tournamentResponse

	return nil
}

func (s *TournamentService) StartTournament(tournamentId uint) errors.IError {
	var tournament models.Tournament

	s.Db.Find(&tournament, tournamentId)

	tournament.Status = models.TournamentStatusStarted

	result := s.Db.Save(&tournament)

	if result.Error != nil {
		return errors.NewErrorResponse(500, result.Error.Error())

	}

	// search for the last step
	lastStep := models.TournamentStep{}
	s.Db.Last(&lastStep, "tournament_id = ?", tournamentId)

	// check all matches in the last step are finished
	matches := []models.Match{}
	s.Db.Find(&matches, "tournament_id = ? AND tournament_step_id = ?", tournamentId, lastStep.ID)

	for _, match := range matches {
		if match.Status != "finished" {
			return errors.NewErrorResponse(500, "All matches in the last step must be finished")
		}

	}

	err := s.GenerateMatchesWithPosition(lastStep.ID, tournamentId)

	if err != nil {

		return errors.NewInternalServerError("Failed to generate matches", err)
	}

	go s.SendTournamentUpdatesForGRPC(tournamentId)
	return nil
}

func (s TournamentService) GenerateMatchesWithPosition(stepId uint, tournamentID uint) errors.IError {

	users := []models.User{}

	tournament := models.Tournament{}
	tournament.ID = tournamentID
	err := s.Db.Model(&tournament).Association("Users").Find(&users)

	if err != nil {
		return errors.NewNotFoundError("Users not found", err)
	}

	rand.Seed(time.Now().UnixNano())
	rand.Shuffle(len(users), func(i, j int) { users[i], users[j] = users[j], users[i] })

	matchPosition := 1
	for i := 0; i < len(users); i += 2 {
		playerOneID := users[i].ID
		var playerTwoID uint
		if i+1 < len(users) {
			playerTwoID = users[i+1].ID
		} else {
			// Handle the case where there is an odd number of players
			// Create a match with only one player and declare him as the winner
			match := models.Match{
				PlayerOneID:      playerOneID,
				TournamentID:     tournamentID,
				TournamentStepID: stepId,
				MatchPosition:    matchPosition,
				Status:           "finished",
				WinnerID:         &playerOneID, // Set PlayerOne as the winner
			}

			if err := s.Db.Create(&match).Error; err != nil {
				return errors.NewInternalServerError("Failed to generate matches", err)
			}

			continue
		}

		match := models.Match{
			PlayerTwoID:      &playerTwoID,
			PlayerOneID:      playerOneID,
			TournamentID:     tournamentID,
			TournamentStepID: stepId,
			MatchPosition:    matchPosition,
		}

		if err := s.Db.Create(&match).Error; err != nil {
			return errors.NewInternalServerError("Failed to generate matches", err)
		}

		matchPosition++
	}
	return nil
}
func (s *TournamentService) CalculateRanking(filterParams *FilterParams) ([]models.UserRanking, errors.IError) {
	var _ models.Tournament
	var matches []models.Match
	query := s.Db.Preload("PlayerOne").Preload("PlayerTwo").Preload("Winner").Preload("Scores")

	if filterParams.Fields["TournamentID"] != nil {
		err := query.Joins("JOIN tournament_steps ON tournament_steps.tournament_id = ?", filterParams.Fields["TournamentID"]).
			Where("matches.tournament_step_id IN (SELECT id FROM tournament_steps WHERE tournament_id = ?)", filterParams.Fields["TournamentID"]).
			Find(&matches).Error
		if err != nil {
			return nil, errors.NewErrorResponse(500, err.Error())
		}
	}

	if filterParams.Fields["TournamentID"] == nil {
		return nil, errors.NewErrorResponse(400, "TournamentID or GameID must be specified")
	}

	userScores := make(map[uint]int)

	for _, match := range matches {
		if match.WinnerID != nil && *match.WinnerID != 0 {
			userScores[*match.WinnerID] += 3
		} else {
			userScores[match.PlayerOneID] += 1
			if *match.PlayerTwoID != 0 {
				userScores[*match.PlayerTwoID] += 1
			}
		}
	}

	var rankings []models.UserRanking
	if filterParams.Fields["UserID"] != nil {
		userID, _ := strconv.ParseUint(filterParams.Fields["UserID"].(string), 10, 64)
		score, exists := userScores[uint(userID)]
		if exists {
			user := models.User{}
			err := s.Db.First(&user, userID).Error
			if err != nil {
				return nil, errors.NewErrorResponse(500, err.Error())
			}
			rankings = append(rankings, models.UserRanking{User: user.ToRead(), Score: score})
		} else {
			return nil, errors.NewErrorResponse(404, "User not found in the specified tournament or game")
		}
	} else {
		for userID, score := range userScores {
			user := models.User{}
			err := s.Db.First(&user, userID).Error
			if err != nil {
				return nil, errors.NewErrorResponse(500, err.Error())
			}
			rankings = append(rankings, models.UserRanking{User: user.ToRead(), Score: score})
		}

		sort.Slice(rankings, func(i, j int) bool {
			return rankings[i].Score > rankings[j].Score
		})
	}

	return rankings, nil
}

func (s *TournamentService) GetGlobalRankings() ([]models.UserRanking, errors.IError) {
	var tournaments []models.Tournament
	err := s.Db.Preload("Steps.Matches.PlayerOne").Preload("Steps.Matches.PlayerTwo").Preload("Steps.Matches.Winner").Preload("Steps.Matches.Scores").Find(&tournaments).Error
	if err != nil {
		return nil, errors.NewErrorResponse(500, err.Error())
	}

	userScores := make(map[uint]int)

	for _, tournament := range tournaments {
		for _, step := range tournament.Steps {
			for _, match := range step.Matches {
				if match.WinnerID != nil && *match.WinnerID != 0 {
					userScores[*match.WinnerID] += 3
				} else {
					userScores[match.PlayerOneID] += 1
					userScores[*match.PlayerTwoID] += 1
				}
			}
		}
	}

	var rankings []models.UserRanking
	for userID, score := range userScores {
		user := models.User{}
		err := s.Db.First(&user, userID).Error
		if err != nil {
			return nil, errors.NewErrorResponse(500, err.Error())
		}
		rankings = append(rankings, models.UserRanking{User: user.ToRead(), Score: score})
	}

	sort.Slice(rankings, func(i, j int) bool {
		return rankings[i].Score > rankings[j].Score
	})

	return rankings, nil
}

func (s *TournamentService) GetAll(models interface{}, filterParams FilterParams, preloads ...string) errors.IError {
	query := s.Db

	for _, preload := range preloads {
		query = query.Preload(preload)
	}

	if _, ok := filterParams.Fields["UserID"]; ok {
		query = query.Joins("JOIN user_tournaments ON user_tournaments.tournament_id = tournaments.id").
			Where("user_tournaments.user_id = ?", filterParams.Fields["UserID"])
	}

	if _, ok := filterParams.Fields["GameID"]; ok {
		query = query.Where("tournaments.game_id = ?", filterParams.Fields["GameID"])
	}
	if _, ok := filterParams.Fields["Name"]; ok {
		query = query.Where("tournaments.name LIKE ?", "%"+filterParams.Fields["Name"].(string)+"%")
	}

	for _, sortField := range filterParams.Sort {
		if strings.HasPrefix(sortField, "-") {
			query = query.Order(sortField[1:] + " desc")
		} else {
			query = query.Order(sortField)
		}
	}

	result := query.Find(models)
	if result.Error != nil {
		return errors.NewErrorResponse(500, result.Error.Error())
	}

	return nil
}

func (s *TournamentService) SendTournamentIsSoon() (string, errors.IError) {
	firebaseClient, errF := firebase.NewFirebaseClient("./firebase/privateKey.json")

	if errF != nil {
		return "", errors.NewInternalServerError("Failed to initialize Firebase", errF)
	}

	tomorow := time.Now().AddDate(0, 0, 1)

	tournaments := []models.Tournament{}

	err := s.Db.Preload("Users").Find(&tournaments, "start_date = ?", tomorow).Error

	if err != nil {
		return "", errors.NewInternalServerError("Failed to get tournaments", err)
	}

	for _, tournament := range tournaments {
		for _, user := range tournament.Users {
			token := user.FCMToken
			title := "Tournament is soon"
			body := "The tournament " + tournament.Name + " is tomorrow"
			_, err := firebaseClient.SendNotification(token, title, body)
			if err != nil {
				return "", errors.NewInternalServerError("Failed to send notification", err)
			}
		}
	}

	return "Successfully sent notification", nil
}

func (s *TournamentService) UserSubscribeToTournaments(userID uint, tournamentID uint) errors.IError {
	user := models.User{}
	tournament := models.Tournament{}

	err := s.Db.First(&user, userID).Error
	if err != nil {
		return errors.NewNotFoundError("User not found", err)
	}

	err = s.Db.First(&tournament, tournamentID).Error
	if err != nil {
		return errors.NewNotFoundError("Tournament not found", err)
	}

	err = s.Db.Model(&user).Association("SuscribedTournaments").Append(&tournament)
	if err != nil {
		return errors.NewInternalServerError("Failed to subscribe to tournament", err)
	}

	return nil
}

func (s *TournamentService) UserUnsubscribeToTournaments(userID uint, tournamentID uint) errors.IError {
	user := models.User{}
	tournament := models.Tournament{}

	err := s.Db.First(&user, userID).Error
	if err != nil {
		return errors.NewNotFoundError("User not found", err)
	}

	err = s.Db.First(&tournament, tournamentID).Error
	if err != nil {
		return errors.NewNotFoundError("Tournament not found", err)
	}

	err = s.Db.Model(&user).Association("SuscribedTournaments").Delete(&tournament)
	if err != nil {
		return errors.NewInternalServerError("Failed to unsubscribe to tournament", err)
	}

	return nil
}

func (s *TournamentService) GetSubscribedTournaments(userID uint, tournaments *[]models.Tournament) errors.IError {
	user := models.User{}
	err := s.Db.Preload("SuscribedTournaments").First(&user, userID).Error
	if err != nil {
		return errors.NewNotFoundError("User not found", err)
	}

	*tournaments = user.SuscribedTournaments

	return nil
}
