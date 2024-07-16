package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	"golang.org/x/crypto/bcrypt"
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
	matchService := NewMatchService(s.Db)
	gameService := NewGameService(s.Db)
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
	errUser := s.Db.Find(&user, userId).Error

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
	err := s.Db.Order("global_score desc").Find(&users).Error
	if err != nil {
		return nil, errors.NewInternalServerError("Failed to get ranks", err)
	}

	return s.mapUsersToUserRankings(users), nil

}

func (s UserService) GetRankByUserID(id uint) (int, errors.IError) {
	var user models.User
	err := s.Db.Find(&models.User{}, id).Select("global_score").Scan(&user).Error

	if err != nil {
		return 0, errors.NewInternalServerError("Failed to get rank", err)
	}

	var count int64
	err = s.Db.Model(&models.User{}).Where("global_score > ?", user.GlobalScore).Count(&count).Error

	if err != nil {
		return 0, errors.NewInternalServerError("Failed to get rank", err)
	}

	return int(count + 1), nil

}

func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 14)
	return string(bytes), err
}

func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func (s UserService) mapUsersToUserRankings(users []models.User) []models.UserRanking {
	var userRankings []models.UserRanking
	for i, user := range users {
		userRankings = append(userRankings, models.UserRanking{
			Rank:  i + 1,
			User:  user.ToRead(),
			Score: user.GlobalScore,
		})
	}
	return userRankings
}

func (s UserService) GetTotalScoreByUserID(id uint) (int, errors.IError) {
	var totalScore int
	err := s.Db.Find(&models.User{}, id).Select("global_score").Scan(&totalScore).Error

	if err != nil {
		return 0, errors.NewInternalServerError("Failed to get total score", err)
	}
	return totalScore, nil
}

func (s UserService) AddFCMToken(userId uint, token string) error {
	user := models.User{}
	err := s.Db.Find(&user, userId).Error

	if err != nil {
		return errors.NewInternalServerError("Failed to find user", err)
	}

	user.FCMToken = token

	err = s.Db.Save(&user).Error

	if err != nil {
		return errors.NewInternalServerError("Failed to save user", err)
	}

	return nil
}

func (s UserService) FindByEmail(email string) (*models.User, error) {
	user := models.User{}
	err := s.Db.Where("email = ?", email).First(&user).Error

	if err != nil {
		return nil, err
	}

	return &user, nil
}
