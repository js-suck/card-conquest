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
	query := s.db
	queryTrendy := s.db

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

	if err := s.db.Preload("Game").Preload("User").Find(&userGamesScores, "user_id = ?", userID).Error; err != nil {
		return nil, errors.NewInternalServerError("Failed to get game scores", err)
	}

	for _, gameScore := range userGamesScores {
		var rank int64

		if err := s.db.Table("game_scores").
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
