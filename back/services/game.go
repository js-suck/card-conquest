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

func (s *GameService) GetAll(filterParams FilterParams, gameParams GameParams, preloads ...string) (trendyGames []models.Game, allGames []models.Game, err errors.IError) {
	query := s.db

	for _, preload := range preloads {
		query = query.Preload(preload)
	}
	// search if in query string there is a parameter with_trendy
	// games who the tounraments are the most recent
	if gameParams.WithTrendy {

		err := query.Joins("JOIN tournaments ON tournaments.game_id = games.id").Group("games.id").Order("tournaments.start_date DESC").Limit(8).Find(&trendyGames).Error
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
