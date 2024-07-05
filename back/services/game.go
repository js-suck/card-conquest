package services

import (
	"authentication-api/errors"
	"authentication-api/models"

	"gorm.io/gorm"
)

type GameParams struct {
	WithTrendy bool `form:"WithTrendy"`
}

type GameService struct {
	// This service can use all the methods of genericService or can override it
	*GenericService
}

func NewGameService(db *gorm.DB) *GameService {
	return &GameService{
		GenericService: NewGenericService(db, models.Game{}),
	}
}

func (s *GameService) GetAll(filterParams FilterParams, gameParams GameParams, preloads ...string) (allGames []models.Game, trendyGames []models.Game, err errors.IError) {
	query := s.Db
	queryTrendy := s.Db

	for _, preload := range preloads {
		query = query.Preload(preload)
		queryTrendy = queryTrendy.Preload(preload)
	}
	// search if in query string there is a parameter with_trendy
	// games who the tounraments are the most recent
	if gameParams.WithTrendy {

		err := queryTrendy.Joins("JOIN tournaments ON tournaments.game_id = games.id").Group("games.id, tournaments.start_date").Order("tournaments.start_date DESC").Limit(8).Find(&trendyGames).Error
		if err != nil {
			return nil, nil, errors.NewErrorResponse(500, err.Error())
		}

		err = queryTrendy.Find(&trendyGames).Error

		if err != nil {
			return nil, nil, errors.NewErrorResponse(500, err.Error())

		}

	}

	// search in db all games
	errorAllGames := query.Find(&allGames).Error

	if errorAllGames != nil {
		return nil, nil, errors.NewErrorResponse(500, err.Error())
	}
	return allGames, trendyGames, nil
}

func (s *GameService) CalculateUserRankingsForGames(userID string) ([]models.UserGameRanking, errors.IError) {
	var userGamesScores []models.GameScore
	var userRankings []models.UserGameRanking

	if err := s.Db.Preload("Game").Preload("User").Find(&userGamesScores, "user_id = ?", userID).Error; err != nil {
		return nil, errors.NewInternalServerError("Failed to get game scores", err)
	}

	for _, gameScore := range userGamesScores {
		var rank int64

		if err := s.Db.Table("game_scores").
			Where("game_id = ?", gameScore.GameID).
			Where("total_score > ?", gameScore.TotalScore).
			Count(&rank).Error; err != nil {
			return nil, errors.NewInternalServerError("Failed to calculate rank", err)
		}

		rank = rank + 1

		userRankings = append(userRankings, models.UserGameRanking{
			User:     gameScore.User.ToRead(),
			GameID:   gameScore.GameID,
			GameName: gameScore.Game.Name,
			Score:    gameScore.TotalScore,
			Rank:     int(rank),
		})
	}

	if len(userRankings) == 0 {
		return nil, errors.NewNotFoundError("No game scores found for user", nil)
	}

	return userRankings, nil
}

func (s *GameService) CreateGame(game *models.Game) errors.IError {
	if err := s.Db.Create(game).Error; err != nil {
		return errors.NewInternalServerError("Failed to create game", err)
	}
	return nil
}

func (s *GameService) UpdateGame(id uint, game *models.Game) errors.IError {
	existingGame := models.Game{}
	if err := s.Db.First(&existingGame, id).Error; err != nil {
		return errors.NewNotFoundError("Game not found", err)
	}

	if err := s.Db.Model(&existingGame).Updates(game).Error; err != nil {
		return errors.NewInternalServerError("Failed to update game", err)
	}

	return nil
}

func (s *GameService) DeleteGame(id uint) errors.IError {
	if err := s.Db.Delete(&models.Game{}, id).Error; err != nil {
		return errors.NewInternalServerError("Failed to delete game", err)
	}
	return nil
}

func (s *GameService) GetGameByID(id uint) (*models.Game, errors.IError) {
	var game models.Game
	if err := s.Db.First(&game, id).Error; err != nil {
		return nil, errors.NewNotFoundError("Game not found", err)
	}
	return &game, nil
}
