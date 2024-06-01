package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	"gorm.io/gorm"
	"strconv"
)

type UserService struct {
	// This service can use all the methods of genericService or can override it
	*GenericService
}

//func (u UserService) Update(m models.IModel) error {
//	//TODO implement me (if you want to override the generic service)
//	panic("implement me")
//}

func NewUserService(db *gorm.DB) *UserService {
	return &UserService{
		GenericService: NewGenericService(db, models.User{}),
	}
}

func (s UserService) GetUserStats(userId uint) (models.UserStats, error) {
	userStats := models.UserStats{}
	matchService := NewMatchService(s.db)
	gameService := NewGameService(s.db)
	totalMatches, err := matchService.GetTotalMatchByUserID(userId)

	if err != nil {
		return userStats, errors.NewInternalServerError("Failed to get total matches", err)

	}

	userStats.TotalMatches = int(totalMatches)

	totalWins, errWins := matchService.GetTotalWinningsByUserID(userId)

	if errWins != nil {
		return userStats, errors.NewInternalServerError("Failed to get total winnings", err)
	}

	userStats.TotalWins = int(totalWins)

	totalLosses, errLosses := matchService.GetTotalLossesByUserID(userId)

	if errLosses != nil {
		return userStats, errors.NewInternalServerError("Failed to get total losses", err)

	}

	userStats.TotalLosses = int(totalLosses)

	totalScore, errScore := s.GetTotalScoreByUserID(userId)

	if errScore != nil {
		return userStats, errors.NewInternalServerError("Failed to get total score", err)
	}

	userStats.TotalScore = totalScore

	user := models.User{}
	errUser := s.db.Find(&user, userId).Error

	if errUser != nil {
		return userStats, errors.NewInternalServerError("Failed to get user", err)
	}

	userRead := user.ToRead()

	userStats.UserReadTournament = &userRead

	userRankings, errRankings := s.GetRankByUserID(userId)

	if errRankings != nil {
		return userStats, errors.NewInternalServerError("Failed to get rank", err)
	}

	userStats.Rank = userRankings

	userStats.GamesRanking, err = gameService.CalculateUserRankingsForGames(strconv.Itoa(int(userId)))

	return userStats, nil
}

func (s UserService) GetRanks() ([]models.UserRanking, errors.IError) {
	var users []models.User
	err := s.db.Order("global_score desc").Find(&users).Error
	if err != nil {
		return nil, errors.NewInternalServerError("Failed to get ranks", err)
	}

	return s.mapUsersToUserRankings(users), nil

}

func (s UserService) GetRankByUserID(id uint) (int, errors.IError) {
	var user models.User
	err := s.db.Find(&models.User{}, id).Select("global_score").Scan(&user).Error

	if err != nil {
		return 0, errors.NewInternalServerError("Failed to get rank", err)
	}

	var count int64
	err = s.db.Model(&models.User{}).Where("global_score > ?", user.GlobalScore).Count(&count).Error

	if err != nil {
		return 0, errors.NewInternalServerError("Failed to get rank", err)
	}

	return int(count + 1), nil

}

func (s UserService) mapUsersToUserRankings(users []models.User) []models.UserRanking {
	var userRankings []models.UserRanking
	for i, user := range users {
		userRankings = append(userRankings, models.UserRanking{
			Rank: i + 1,
			User: user.ToRead(),
		})
	}
	return userRankings
}

func (s UserService) GetTotalScoreByUserID(id uint) (int, errors.IError) {
	var totalScore int
	err := s.db.Find(&models.User{}, id).Select("global_score").Scan(&totalScore).Error

	if err != nil {
		return 0, errors.NewInternalServerError("Failed to get total score", err)
	}
	return totalScore, nil
}
