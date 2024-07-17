package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	authentication_api "authentication-api/pb/github.com/lailacha/authentication-api"
	_ "errors"
	"fmt"
	"gorm.io/gorm"
	"log"
	"math/rand"
	"sort"
	"strings"
	"time"
)

type MatchService struct {
	*GenericService
}

var MatchUpdates = make(chan *authentication_api.MatchResponse, 100)

func NewMatchService(db *gorm.DB) *MatchService {
	return &MatchService{
		GenericService: NewGenericService(db, models.Match{}),
	}
}

func (s MatchService) UpdateScore(matchId uint, score *models.Score, userId int) errors.IError {
	match := models.Match{}
	tournamentService := NewTournamentService(s.Db)

	if err := s.Db.First(&match, matchId).Error; err != nil {
		return errors.NewNotFoundError("Match not found", err)
	}

	var scores []models.Score
	s.Db.Model(&match).Association("Scores").Find(&scores, "player_id = ?", userId)

	if scores == nil || len(scores) == 0 {
		score.MatchID = match.ID
		score.PlayerID = uint(userId)
		if err := s.Db.Create(&score).Error; err != nil {
			return errors.NewInternalServerError("Failed to create score", err)
		}
	} else {
		score.ID = scores[0].ID

		if err := s.Db.Save(&score).Error; err != nil {
			return errors.NewInternalServerError("Failed to update score", err)
		}
	}

	if score.Score == 2 {
		match.WinnerID = &score.PlayerID
		match.Status = "finished"
		if err := s.Db.Save(&match).Error; err != nil {
			return errors.NewInternalServerError("Failed to finish match", err)
		}

		// check if there is still matches in the current step that are not finished
		var matches []models.Match
		s.Db.Find(&matches, "tournament_step_id = ? AND status != ?", match.TournamentStepID, "finished")

		// verify if there are more than one match in the current step
		var matchCount int64
		s.Db.Model(&models.Match{}).Where("tournament_id = ? AND tournament_step_id = ?", match.TournamentID, match.TournamentStepID).Count(&matchCount)

		if matchCount == 1 {
			match.WinnerID = &score.PlayerID
			match.Status = "finished"
			s.Db.Save(&match)
			tournament := models.Tournament{}
			s.Db.First(&tournament, match.TournamentID)
			tournament.Status = "finished"
			s.Db.Save(&tournament)

			go tournamentService.SendTournamentUpdatesForGRPC(match.TournamentID)
			go s.SendMatchUpdatesForGRPC(match.ID)

			return nil
		}

		if len(matches) == 0 {
			if err := s.GenerateFuturMatchesAndNewStep(match.TournamentID); err != nil {
				return err
			}
		}
		go tournamentService.SendTournamentUpdatesForGRPC(match.TournamentID)
		go s.SendMatchUpdatesForGRPC(match.ID)

		return nil
	}

	go tournamentService.SendTournamentUpdatesForGRPC(match.TournamentID)
	go s.SendMatchUpdatesForGRPC(match.ID)

	return nil
}
func (s MatchService) GenerateFuturMatchesAndNewStep(tournamentId uint) errors.IError {

	// get the last step
	lastStep := models.TournamentStep{}
	if err := s.Db.Last(&lastStep, "tournament_id = ?", tournamentId).Error; err != nil {
		return errors.NewNotFoundError("Step not found", err)
	}

	// get all matches in the last step
	matches := []models.Match{}
	if err := s.Db.Find(&matches, "tournament_step_id = ?", lastStep.ID).Error; err != nil {
		return errors.NewNotFoundError("Matches not found", err)
	}

	// Create a map to store the winners of the last matches with their match position
	lastMatchWinners := make(map[uint]int)
	for _, match := range matches {
		if match.WinnerID != nil {
			lastMatchWinners[*match.WinnerID] = match.MatchPosition
		}
	}

	// create the next step
	nextStep := models.TournamentStep{
		TournamentID: tournamentId,
		Sequence:     lastStep.Sequence + 1,
	}

	if err := s.Db.Create(&nextStep).Error; err != nil {
		return errors.NewInternalServerError("Failed to create step", err)

	}

	// Sort this map by match position
	var sortedWinners []models.User
	for winnerID := range lastMatchWinners {
		winner := models.User{}
		if err := s.Db.First(&winner, winnerID).Error; err != nil {
			return errors.NewNotFoundError("Winner not found", err)
		}
		sortedWinners = append(sortedWinners, winner)
	}
	sort.Slice(sortedWinners, func(i, j int) bool {
		return lastMatchWinners[sortedWinners[i].ID] < lastMatchWinners[sortedWinners[j].ID]
	})

	matchPosition := uint(0)
	for i := 0; i < len(sortedWinners); i += 2 {
		if i+1 < len(sortedWinners) {
			playerTwoID := sortedWinners[i+1].ID
			match := models.Match{
				PlayerOneID:      sortedWinners[i].ID,
				PlayerTwoID:      &playerTwoID,
				TournamentID:     tournamentId,
				TournamentStepID: nextStep.ID,
				MatchPosition:    int(matchPosition),
			}
			if err := s.Db.Create(&match).Error; err != nil {
				return errors.NewInternalServerError("Failed to generate matches", err)
			}
		} else if i == len(sortedWinners)-1 { // If we have an odd number of winners
			// Here, we automatically pass the last winner to the next round (bye)
			match := models.Match{
				PlayerOneID:      sortedWinners[i].ID,
				TournamentID:     tournamentId,
				TournamentStepID: nextStep.ID,
				MatchPosition:    int(matchPosition),
				WinnerID:         &sortedWinners[i].ID, // Declare the match winner
				Status:           "finished",           // Mark the match as finished
			}
			if err := s.Db.Create(&match).Error; err != nil {
				return errors.NewInternalServerError("Failed to generate matches", err)
			}
		}
		matchPosition++
	}

	return nil
}

func (s MatchService) GenerateMatches(tournamentId uint) errors.IError {
	tournament := models.Tournament{}
	if err := s.Db.First(&tournament, tournamentId).Error; err != nil {
		return errors.NewNotFoundError("Tournament not found", err)
	}

	// get all users in the tournament
	var users []models.User
	err := s.Db.Model(&tournament).Association("Users").Find(&users)
	if err != nil {
		return errors.NewNotFoundError("Users not found", err)
	}
	// get all steps in the tournament
	var steps []models.TournamentStep
	s.Db.Find(&steps, "tournament_id = ?", tournamentId)
	// get the last step
	lastStep := steps[len(steps)-1]

	// if the last step has less than two matches, finish the tournament
	matches := []models.Match{}
	s.Db.Find(&matches, "tournament_step_id = ?", lastStep.ID)
	if len(matches) < 2 {
		tournament.Status = "finished"
		if err := s.Db.Save(&tournament).Error; err != nil {
			return errors.NewInternalServerError("Failed to finish tournament", err)
		}
		return nil
	}

	// check if all matches in the last step are finished
	for _, match := range matches {
		if match.Status != "finished" {
			return errors.NewBadRequestError("Not all matches in the last step are finished", nil)
		}
	}

	// if there are no steps, create the first one and generate matches
	if len(steps) == 0 {
		step := models.TournamentStep{
			TournamentID: tournament.ID,
			Sequence:     1,
		}
		if err := s.Db.Create(&step).Error; err != nil {
			return errors.NewInternalServerError("Failed to create step", err)
		}
		return s.generateMatchesForStep(users, step.ID, tournament.ID)
	}

	// create the next step and generate matches with the winners of the last step
	nextStep := models.TournamentStep{
		TournamentID: tournament.ID,
		Sequence:     lastStep.Sequence + 1,
	}
	if err := s.Db.Create(&nextStep).Error; err != nil {
		return errors.NewInternalServerError("Failed to create step", err)
	}

	winners := []models.User{}
	for _, match := range matches {
		winner := models.User{}
		if err := s.Db.First(&winner, match.WinnerID).Error; err != nil {
			return errors.NewNotFoundError("Winner not found", err)
		}
		winners = append(winners, winner)
	}

	return s.generateMatchesForStep(winners, nextStep.ID, tournament.ID)
}

func (s MatchService) generateMatchesForStep(users []models.User, stepId uint, tournamentID uint) errors.IError {
	rand.Seed(time.Now().UnixNano())
	rand.Shuffle(len(users), func(i, j int) { users[i], users[j] = users[j], users[i] })

	for i := 0; i < len(users); i += 2 {
		playerOneID := users[i].ID
		var playerTwoID uint
		if i+1 < len(users) {
			playerTwoID = users[i+1].ID
		} else {
			continue
		}

		match := models.Match{
			PlayerTwoID:      &playerTwoID,
			PlayerOneID:      playerOneID,
			TournamentID:     tournamentID,
			TournamentStepID: stepId,
		}

		if err := s.Db.Create(&match).Error; err != nil {
			return errors.NewInternalServerError("Failed to generate matches", err)
		}
	}
	return nil
}

func (s MatchService) GetTournamentMatches(u uint) ([]models.Match, errors.IError) {
	var matches []models.Match
	if err := s.Db.Find(&matches, "tournament_id = ?", u).Error; err != nil {
		return nil, errors.NewInternalServerError("Failed to get matches", err)
	}
	return matches, nil
}

func (s MatchService) GetMatchPlayers(u uint) (*models.User, *models.User, errors.IError) {
	match := models.Match{}
	if err := s.Db.Preload("PlayerOne").Preload("PlayerTwo").First(&match, u).Error; err != nil {
		return nil, nil, errors.NewInternalServerError("Failed to get match", err)
	}
	return &match.PlayerOne, &match.PlayerTwo, nil
}

func (s *MatchService) GetAll(models interface{}, filterParams FilterParams, preloads ...string) errors.IError {
	query := s.Db

	if userID, ok := filterParams.Fields["UserID"]; ok {
		query = query.Where("player_one_id = ? OR player_two_id = ?", userID, userID)
	}

	if status, ok := filterParams.Fields["Status"]; ok {
		query = query.Where("status = ?", status)
	}

	if unfinished, ok := filterParams.Fields["Unfinished"]; ok {
		if unfinished == "true" {
			query = query.Where("status != ?", "finished")
		}
	}

	query = query.Preload("PlayerOne").Preload("PlayerTwo").Preload("Tournament").Preload("TournamentStep").Preload("Scores").Preload("Winner")

	for _, preload := range preloads {
		query = query.Preload(preload)
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

func (s *MatchService) GetMatchesBetweenUsers(userID1, userID2 uint, filter FilterParams) ([]models.Match, errors.IError) {
	var matches []models.Match

	query := s.Db.Preload("Tournament").Preload("TournamentStep").Preload("PlayerOne").Preload("PlayerTwo").Preload("Winner").Preload("Scores").
		Where("(player_one_id = ? AND player_two_id = ?) OR (player_one_id = ? AND player_two_id = ?)", userID1, userID2, userID2, userID1).
		Preload("PlayerOne").
		Preload("PlayerTwo").
		Preload("Winner")

	if status, ok := filter.Fields["Status"]; ok {
		query = query.Where("status = ?", status)
	}

	if err := query.Find(&matches).Error; err != nil {
		return nil, errors.NewInternalServerError("Failed to get matches", err)
	}

	return matches, nil
}

func (s MatchService) GetTotalMatchByUserID(id uint) (int64, errors.IError) {

	var totalMatch int64

	err := s.Db.Model(&models.Match{}).Where("player_one_id = ? OR player_two_id = ?", id, id).Count(&totalMatch).Error

	if err != nil {
		return 0, errors.NewInternalServerError("Failed to get total match", nil)
	}

	return totalMatch, nil
}

func (s MatchService) GetTotalWinningsByUserID(id uint) (int64, errors.IError) {

	var totalWinnings int64

	err := s.Db.Model(&models.Match{}).Where("winner_id = ?", id).Count(&totalWinnings).Error

	if err != nil {
		return 0, errors.NewInternalServerError("Failed to get total winnings", nil)
	}

	return totalWinnings, nil
}

func (s MatchService) GetTotalLossesByUserID(id uint) (int64, errors.IError) {

	var totalLosses int64

	err := s.Db.Model(&models.Match{}).Where("(player_one_id = ? OR player_two_id = ?) AND winner_id != ?", id, id, id).Count(&totalLosses).Error

	if err != nil {
		return 0, errors.NewInternalServerError("Failed to get total losses", nil)
	}

	return totalLosses, nil
}

func (s MatchService) SendMatchUpdatesForGRPC(u uint) {

	match := models.Match{}

	if err := s.Db.Preload("PlayerOne").
		Preload("PlayerTwo").
		Preload("PlayerTwo.Media").
		Preload("PlayerOne.Media").
		Preload("Tournament").
		Preload("TournamentStep").
		Preload("Scores").
		Joins("LEFT JOIN scores ON scores.match_id = matches.id").
		Order("scores.created_at desc").
		First(&match, u).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			log.Printf("No match found with the specified criteria")
			return
		} else {
			log.Printf("Error fetching match: %v", err)
			return
		}
	}

	// reverses matches.scores
	sort.Slice(match.Scores, func(i, j int) bool {
		return match.Scores[i].UpdatedAt.Before(match.Scores[j].UpdatedAt)
	})

	var playerOneScore, playerTwoScore int
	for _, score := range match.Scores {
		if score.PlayerID == match.PlayerOneID {
			playerOneScore = score.Score
		} else if score.PlayerID == *match.PlayerTwoID {
			playerTwoScore = score.Score
		}
	}

	userService := NewUserService(s.Db)
	userRank, err := userService.GetRankByUserID(match.PlayerOneID)
	if err != nil {
		fmt.Println(err)
	}

	playerTwoRank, err := userService.GetRankByUserID(*match.PlayerTwoID)

	if err != nil {
		fmt.Println(err)

	}
	update := &authentication_api.MatchResponse{}

	update = &authentication_api.MatchResponse{
		MatchId:   int32(uint32(match.ID)),
		Status:    match.Status,
		Location:  match.Tournament.Location,
		StartDate: match.StartTime.Format(time.RFC3339),
		PlayerOne: &authentication_api.PlayerMatch{
			Id:       int32(uint32(match.PlayerOne.ID)),
			Username: match.PlayerOne.Username,
			Rank:     int32(userRank),
			Score:    int32(playerOneScore),
		},
		PlayerTwo: &authentication_api.PlayerMatch{
			Id:       int32(uint32(match.PlayerTwo.ID)),
			Username: match.PlayerTwo.Username,
			Rank:     int32(playerTwoRank),
			Score:    int32(playerTwoScore),
		},
	}

	if match.WinnerID != nil {
		update.WinnerId = int32(uint32(*match.WinnerID))
	}

	if match.PlayerOne.Media != nil {
		update.PlayerOne.MediaUrl = match.PlayerOne.Media.FileName
	}

	if match.PlayerTwo.Media != nil {
		update.PlayerTwo.MediaUrl = match.PlayerTwo.Media.FileName
	}

	MatchUpdates <- update

}
