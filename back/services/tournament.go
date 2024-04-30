package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	"fmt"
	"gorm.io/gorm"
	"math/rand"
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

func (s TournamentService) RegisterUser(userId uint, tournamentId uint) errors.IError {
	tournament := models.Tournament{}
	user := models.User{}

	if err := s.db.First(&tournament, tournamentId).Error; err != nil {
		return errors.NewNotFoundError("Tournament not found", err)
	}

	if err := s.db.First(&user, userId).Error; err != nil {
		return errors.NewNotFoundError("User not found", err)
	}

	tournament.Users = append(tournament.Users, &user)

	if err := s.db.Save(&tournament).Error; err != nil {
		return errors.NewInternalServerError("Failed to register user to tournament", err)
	}

	return nil
}
func (s TournamentService) GenerateMatches(tournamentId uint) errors.IError {
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

func (s TournamentService) generateMatchesForStep(users []models.User, stepId uint, tournamentID uint) errors.IError {
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
			PlayerTwoID:      playerTwoID,
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
func (s TournamentService) FinishMatch(matchID uint, winnderID uint) errors.IError {
	match := models.Match{}

	if err := s.db.First(&match, matchID).Error; err != nil {
		return errors.NewNotFoundError("Match not found", err)
	}

	match.Status = "finished"
	match.WinnerID = &winnderID

	if err := s.db.Save(&match).Error; err != nil {
		return errors.NewInternalServerError("Failed to finish match", err)
	}

	// search if there is other match without finished status
	pendingMatchs := []models.Match{}
	s.db.Find(&pendingMatchs, "tournament_id = ? AND status = ? AND tournament_step_id = ?", match.TournamentID, "started", match.TournamentStepID)

	// search the last match and its tournament
	s.db.Last(&match, "tournament_id = ?", match.TournamentID)

	// search how many users have finished the last step
	lastStep := models.TournamentStep{}
	s.db.First(&lastStep, "tournament_id = ?", match.TournamentID)

	// search if there is more than one match in the last step

	var lastMatchCount int64
	s.db.Model(&models.Match{}).Where("tournament_id = ? AND tournament_step_id = ?", match.TournamentID, lastStep.ID).Count(&lastMatchCount)

	// if there is only one match, the winner of the match is the winner of the tournament

	if lastMatchCount == 1 {
		match.WinnerID = &match.PlayerOneID
		match.Status = "finished"
		s.db.Save(&match)
		tournament := models.Tournament{}
		s.db.First(&tournament, match.TournamentID)
		tournament.Status = "finished"
		s.db.Save(&tournament)
		return nil
	}

	fmt.Println("pendingMatchs", pendingMatchs, len(pendingMatchs))
	// if there is more than one match, check if all matches are finished
	if len(pendingMatchs) == 0 {
		// get all matches in the last step
		matches := []models.Match{}
		s.db.Find(&matches, "tournament_id = ? AND tournament_step_id = ?", match.TournamentID, lastStep.ID)

		// get all winners in the last step
		winners := []models.User{}
		for _, match := range matches {
			winner := models.User{}
			s.db.First(&winner, match.WinnerID)
			winners = append(winners, winner)
		}

		// if all winners are different, generate the next step
		if len(winners) == len(matches) {
			return s.GenerateMatches(match.TournamentID)
		}
	}

	return nil

}
