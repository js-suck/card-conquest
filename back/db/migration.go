package db

import (
	"authentication-api/models"
	"fmt"
	"gorm.io/gorm"
	"time"
)

const FirstTournamentName = "Test"

func gameMigration(db *gorm.DB) (*models.Game, error) {
	err := db.AutoMigrate(&models.Game{})

	media := models.Media{
		BaseModel:     models.BaseModel{},
		FileName:      "lorcana.jpg",
		FileExtension: "jpg",
	}

	db.Create(&media)

	// create a game
	game := models.Game{
		Name: "Test",
	}

	game.MediaModel.Media = &media

	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}

	db.Create(&game)

	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}
	return &game, nil
}

func tournamentMigration(db *gorm.DB, game *models.Game) (*models.Tournament, error) {
	err := db.AutoMigrate(&models.Tournament{})

	// create a tournament
	tournament := models.Tournament{
		Name:      FirstTournamentName,
		Location:  "",
		UserID:    uint(1),
		GameID:    game.ID,
		StartDate: "2024-04-12T00:00:00Z",
		EndDate:   "2024-05-12T00:00:00Z",
	}

	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}

	db.Create(&tournament)
	return &tournament, nil

}

func registrationsTournamentMigrations(db *gorm.DB) {

	for i := 0; i < 10; i++ {
		user := models.User{
			Username: fmt.Sprintf("Test%d", i),
			Password: "Test",
			Email:    fmt.Sprintf("Test%d•gmail.com", i),
			Role:     "user",
		}

		db.Create(&user)

		tournament := models.Tournament{}

		db.First(&tournament, "name = ?", FirstTournamentName)

		tournament.Users = append(tournament.Users, &user)

		db.Save(&tournament)

	}

}

func mediaMigration(db *gorm.DB) (*models.Media, error) {
	err := db.AutoMigrate(&models.Media{})

	media := models.Media{
		BaseModel:     models.BaseModel{},
		FileName:      "test.jpg",
		FileExtension: "jpg",
	}

	db.Create(&media)

	if err != nil {
		fmt.Println(err.Error())
		return nil, err

	}

	return &media, nil
}
func matchMigration(db *gorm.DB, tournament *models.Tournament) (*models.Match, error) {
	err := db.AutoMigrate(&models.Match{})

	// create tournament step

	tournamentStep := models.TournamentStep{
		TournamentID: tournament.ID,
		Name:         "First step",
		Sequence:     1,
	}

	db.Create(&tournamentStep)

	// create a match
	match := models.Match{
		BaseModel:        models.BaseModel{},
		TournamentID:     tournament.ID,
		Tournament:       models.Tournament{},
		TournamentStepID: 1,
		PlayerOneID:      1,
		PlayerTwoID:      2,
		StartTime:        time.Time{},
		EndTime:          time.Time{},
		Status:           "started",
		WinnerID:         nil,
		Winner:           models.User{},
		Scores:           nil,
	}

	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}

	db.Create(&match)
	return &match, nil
}

func MigrateDatabase(db *gorm.DB) error {

	// remove the old database
	err := db.Migrator().DropTable(&models.User{})
	err = db.Migrator().DropTable(&models.Tournament{})
	err = db.Migrator().DropTable(&models.Game{})
	err = db.Migrator().DropTable(&models.Media{})
	err = db.Migrator().DropTable(&models.TournamentStep{})
	err = db.Migrator().DropTable(&models.Match{})

	if err != nil {
		return err
	}

	err = db.AutoMigrate(&models.User{})
	err = db.AutoMigrate(&models.TournamentStep{})
	err = db.AutoMigrate(&models.Tag{})
	err = db.AutoMigrate(&models.Tournament{})
	err = db.AutoMigrate(&models.Game{})
	err = db.AutoMigrate(&models.Match{})
	err = db.AutoMigrate(&models.Media{})
	var user models.User

	db.First(&user, "username = ?", "user")
	_, err = mediaMigration(db)

	if user.ID == 0 {
		user = models.User{Username: "user", Password: "password", Email: "test@example.com", Role: "admin"}
		db.Create(&user)
	}

	game, err := gameMigration(db)

	t, err := tournamentMigration(db, game)

	registrationsTournamentMigrations(db)
	_, err = matchMigration(db, t)

	if err != nil {
		fmt.Println(err.Error())
		return err
	}

	return nil
}
