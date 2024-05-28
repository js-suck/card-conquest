package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	"gorm.io/gorm"
	"math/rand"
	"sort"
	"strings"
	"time"
)

type MatchService struct {
	*GenericService
}

func NewMatchService(db *gorm.DB) *MatchService {
	return &MatchService{
		GenericService: NewGenericService(db, models.Match{}),
	}
}

func (s MatchService) UpdateScore(matchId uint, score *models.Score, userId int) errors.IError {
	match := models.Match{}
	if err := s.db.First(&match, matchId).Error; err != nil {
		return errors.NewNotFoundError("Match not found", err)
	}

	var scores []models.Score
	s.db.Model(&match).Association("Scores").Find(&scores, "player_id = ?", userId)

	if scores == nil || len(scores) == 0 {
		score.MatchID = match.ID
		score.PlayerID = uint(userId)
		if err := s.db.Create(&score).Error; err != nil {
			return errors.NewInternalServerError("Failed to create score", err)
		}
	} else {
		score.ID = scores[0].ID

		if err := s.db.Save(&score).Error; err != nil {
			return errors.NewInternalServerError("Failed to update score", err)
		}
	}

	if score.Score == 2 {
		match.WinnerID = &score.PlayerID
		match.Status = "finished"
		if err := s.db.Save(&match).Error; err != nil {
			return errors.NewInternalServerError("Failed to finish match", err)
		}

		// check if there is still matches in the current step that are not finished
		var matches []models.Match
		s.db.Find(&matches, "tournament_step_id = ? AND status = ?", match.TournamentStepID, "started")

		// verify if there are more than one match in the current step
		var matchCount int64
		s.db.Model(&models.Match{}).Where("tournament_id = ? AND tournament_step_id = ?", match.TournamentID, match.TournamentStepID).Count(&matchCount)

		if matchCount == 1 {
			match.WinnerID = &match.PlayerOneID
			match.Status = "finished"
			s.db.Save(&match)
			tournament := models.Tournament{}
			s.db.First(&tournament, match.TournamentID)
			tournament.Status = "finished"
			s.db.Save(&tournament)
			return nil
		}

		if len(matches) == 0 {
			if err := s.GenerateFuturMatchesAndNewStep(match.TournamentID); err != nil {
				return err
			}
		}

	}

	tournamentService := NewTournamentService(s.db)

	tournamentService.SendTournamentUpdatesForGRPC(match.TournamentID)

	return nil
}
func (s MatchService) GenerateFuturMatchesAndNewStep(tournamentId uint) errors.IError {

	// get the last step
	lastStep := models.TournamentStep{}
	if err := s.db.Last(&lastStep, "tournament_id = ?", tournamentId).Error; err != nil {
		return errors.NewNotFoundError("Step not found", err)
	}

	// get all matches in the last step
	matches := []models.Match{}
	if err := s.db.Find(&matches, "tournament_step_id = ?", lastStep.ID).Error; err != nil {
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

	if err := s.db.Create(&nextStep).Error; err != nil {
		return errors.NewInternalServerError("Failed to create step", err)

	}

	// Sort this map by match position
	var sortedWinners []models.User
	for winnerID := range lastMatchWinners {
		winner := models.User{}
		if err := s.db.First(&winner, winnerID).Error; err != nil {
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
			if err := s.db.Create(&match).Error; err != nil {
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
			if err := s.db.Create(&match).Error; err != nil {
				return errors.NewInternalServerError("Failed to generate matches", err)
			}
		}
		matchPosition++
	}

	return nil
}

func (s MatchService) GenerateMatches(tournamentId uint) errors.IError {
	tournament := models.Tournament{}
	if err := s.db.First(&tournament, tournamentId).Error; err != nil {
		return errors.NewNotFoundError("Tournament not found", err)
	}

	// get all users in the tournament
	var users []models.User
	err := s.db.Model(&tournament).Association("Users").Find(&users)
	if err != nil {
		return errors.NewNotFoundError("Users not found", err)
	}

	// get all steps in the tournament
	var steps []models.TournamentStep
	s.db.Find(&steps, "tournament_id = ?", tournamentId)

	// if there are no steps, create the first one and generate matches
	if len(steps) == 0 {
		step := models.TournamentStep{
			TournamentID: tournament.ID,
			Sequence:     1,
		}
		if err := s.db.Create(&step).Error; err != nil {
			return errors.NewInternalServerError("Failed to create step", err)
		}
		return s.generateMatchesForStep(users, step.ID, tournament.ID)
	}

	// get the last step
	lastStep := steps[len(steps)-1]

	// if the last step has less than two matches, finish the tournament
	matches := []models.Match{}
	s.db.Find(&matches, "tournament_step_id = ?", lastStep.ID)
	if len(matches) < 2 {
		tournament.Status = "finished"
		if err := s.db.Save(&tournament).Error; err != nil {
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

	// create the next step and generate matches with the winners of the last step
	nextStep := models.TournamentStep{
		TournamentID: tournament.ID,
		Sequence:     lastStep.Sequence + 1,
	}
	if err := s.db.Create(&nextStep).Error; err != nil {
		return errors.NewInternalServerError("Failed to create step", err)
	}

	winners := []models.User{}
	for _, match := range matches {
		winner := models.User{}
		if err := s.db.First(&winner, match.WinnerID).Error; err != nil {
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

		if err := s.db.Create(&match).Error; err != nil {
			return errors.NewInternalServerError("Failed to generate matches", err)
		}
	}
	return nil
}

func (s MatchService) GetTournamentMatches(u uint) ([]models.Match, errors.IError) {
	var matches []models.Match
	if err := s.db.Find(&matches, "tournament_id = ?", u).Error; err != nil {
		return nil, errors.NewInternalServerError("Failed to get matches", err)
	}
	return matches, nil
}

func (s *MatchService) GetAll(models interface{}, filterParams FilterParams, preloads ...string) errors.IError {
	query := s.db

	if _, ok := filterParams.Fields["UserID"]; ok {
		query = query.Where("player_one_id"+" = ?", filterParams.Fields["UserID"]).Or("player_two_id"+" = ?", filterParams.Fields["UserID"])
	}

	if _, ok := filterParams.Fields["TournamentID"]; ok {
		query = query.Where("tournament_id"+" = ?", filterParams.Fields["TournamentID"])

	}

	query = query.Preload("PlayerOne").Preload("PlayerTwo").Preload("Tournament").Preload("TournamentStep").Preload("Scores")

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
