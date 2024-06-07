package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	"gorm.io/gorm"
	"sort"
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

func (s *GameService) GetAll(filterParams FilterParams, gameParams GameParams, preloads ...string) (trendyGames []models.Game, allGames []models.Game, err errors.IError) {
	query := s.db

	for _, preload := range preloads {
		query = query.Preload(preload)
	}
	// search if in query string there is a parameter with_trendy
	// games who the tounraments are the most recent
	if gameParams.WithTrendy {

		err := query.Joins("JOIN tournaments ON tournaments.game_id = games.id").Group("games.id, tournaments.start_date").Order("tournaments.start_date DESC").Limit(8).Find(&trendyGames).Error
		if err != nil {
			return nil, nil, errors.NewErrorResponse(500, err.Error())
		}

		// search in db all games
		err = query.Find(&allGames).Error

		if err != nil {
			return nil, nil, errors.NewErrorResponse(500, err.Error())
		}
	} else {
		// search in db all games
		err := query.Find(&allGames).Error

		if err != nil {
			return nil, nil, errors.NewErrorResponse(500, err.Error())
		}
	}

	return trendyGames, allGames, nil
}

func (s *GameService) CalculateUserRankings(userID string) ([]models.UserGameRanking, errors.IError) {
	// get all the games
	var games []models.Game

	err := s.db.Preload("Tournaments.Steps.Matches").Find(&games).Error
	if err != nil {
		return nil, errors.NewErrorResponse(500, err.Error())
	}

	userScores := make(map[uint]int)

	// map and get calculate the points of all users
	for _, game := range games {
		for _, tournament := range game.Tournaments {
			for _, step := range tournament.Steps {
				for _, match := range step.Matches {
					if match.WinnerID != nil && *match.WinnerID != 0 {
						userScores[*match.WinnerID] += 3
					} else {
						userScores[match.PlayerOneID] += 1
						if *match.PlayerTwoID != 0 {
							userScores[*match.PlayerTwoID] += 1
						}
					}
				}
			}
		}
	}

	// for each score, give 3 to the winner and 1 to the others
	var rankings []models.UserGameRanking
	for userID, score := range userScores {
		user := models.User{}
		err := s.db.First(&user, userID).Error
		if err != nil {
			return nil, errors.NewErrorResponse(500, err.Error())
		}
		rankings = append(rankings, models.UserGameRanking{User: user.ToRead(), Score: score})
	}

	// get the userID index
	sort.Slice(rankings, func(i, j int) bool {
		return rankings[i].Score > rankings[j].Score
	})

	// return the ranking
	return rankings, nil
}
