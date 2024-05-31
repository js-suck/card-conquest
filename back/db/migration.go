package db

import (
	"authentication-api/models"
	"fmt"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"log"
	"os"
	"time"
)

const FirstTournamentName = "Test"

func gameMigration(db *gorm.DB) (*models.Game, error) {
	err := db.AutoMigrate(&models.Game{})

	// create multiple games at once
	for i := 1; i < 25; i++ {
		game := models.Game{
			Name: fmt.Sprintf("Test%d", i),
		}

		if err != nil {
			fmt.Println(err.Error())
			return nil, err
		}

		db.Create(&game)
	}

	// create a game
	game := models.Game{
		Name: "Test",
	}

	db.Create(&game) // create a game

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
		Name:       FirstTournamentName,
		Location:   "",
		UserID:     uint(1),
		GameID:     game.ID,
		StartDate:  "2024-04-12T00:00:00Z",
		EndDate:    "2024-05-12T00:00:00Z",
		MaxPlayers: 32,
	}

	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}

	db.Create(&tournament)
	return &tournament, nil

}

func registrationsTournamentMigrations(db *gorm.DB) {

	media := models.Media{
		BaseModel:     models.BaseModel{},
		FileName:      "yugiho.webp",
		FileExtension: "webp",
	}
	tournament := models.Tournament{}

	db.First(&tournament, "name = ?", FirstTournamentName)

	tournament.MediaModel.Media = &media

	db.Create(&media)
	tournamentStep := models.TournamentStep{
		TournamentID: tournament.ID,
		Name:         "First step",
		Sequence:     1,
	}

	db.Create(&tournamentStep)

	for i := 0; i < 10; i++ {
		user := models.User{
			Username: fmt.Sprintf("Test%d", i),
			Password: "Test",
			Email:    fmt.Sprintf("Test%d•gmail.com", i),
			Role:     "user",
		}

		db.Create(&user)
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
func matchMigration(db *gorm.DB, tournament *models.Tournament, user *models.User) (*models.Match, error) {
	err := db.AutoMigrate(&models.Match{})

	// create tournament step

	playerTwoId := uint(2)

	// create a match
	match := models.Match{
		BaseModel:        models.BaseModel{},
		TournamentID:     tournament.ID,
		Tournament:       models.Tournament{},
		TournamentStepID: 1,
		PlayerOneID:      1,
		PlayerTwoID:      &playerTwoId,
		StartTime:        time.Time{},
		EndTime:          time.Time{},
		Status:           "started",
		WinnerID:         &user.ID,
		Scores:           nil,
	}

	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}

	db.Create(&match)

	// add score

	return &match, nil
}

func MigrateDatabase() error {
	err := godotenv.Load(".env")
	if err != nil {
		log.Fatalf("Erreur lors du chargement du fichier .env: %v", err)
	}

	dbHost := os.Getenv("DATABASE_HOST")
	dbPort := os.Getenv("DATABASE_PORT")
	dbUser := os.Getenv("DATABASE_USERNAME")
	dbPassword := os.Getenv("DATABASE_PASSWORD")
	dbName := os.Getenv("DATABASE_NAME")

	dsn := fmt.Sprintf("user=%s password=%s dbname=%s host=%s port=%s sslmode=disable TimeZone=Asia/Shanghai", dbUser, dbPassword, dbName, dbHost, dbPort)
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	// remove the old database
	err = db.Migrator().DropTable(&models.User{})
	err = db.Migrator().DropTable(&models.Tournament{})
	err = db.Migrator().DropTable(&models.Game{})
	err = db.Migrator().DropTable(&models.Media{})
	err = db.Migrator().DropTable(&models.TournamentStep{})
	err = db.Migrator().DropTable(&models.Match{})
	err = db.Migrator().DropTable(&models.Score{})

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
	err = db.AutoMigrate(&models.Score{})

	var user models.User

	db.First(&user, "username = ?", "user")
	_, err = mediaMigration(db)

	if user.ID == 0 {
		user = models.User{Username: "user", Password: "password", Email: "test@example.com", Role: "admin"}
		db.Create(&user)
	}

	game, err := gameMigration(db)

	_, err = tournamentMigration(db, game)

	registrationsTournamentMigrations(db)
	//_, err = matchMigration(db, t, &user)

	if err != nil {
		fmt.Println(err.Error())
		return err
	}

	return nil
}
