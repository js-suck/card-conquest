package db

import (
	"authentication-api/models"
	"authentication-api/services"
	"fmt"
	"github.com/bxcodec/faker/v3"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"log"
	"os"
	"time"
)

const FirstTournamentName = "Yu-Gi-Oh! Championship"
const SecondTournamentName = "Magic: The Gathering Tournament"
const ThirdTournamentName = "Pokémon TCG Tournament"

var tournamentsFixtures = []models.Tournament{
	{
		ID:        1,
		BaseModel: models.BaseModel{},
		Name:      FirstTournamentName,
		Location:  "New York",
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "yugioh.jpeg",
				FileExtension: "jpeg",
			},
		},
		UserID:     3,
		GameID:     1,
		Rounds:     3,
		MaxPlayers: 32,
		Longitude:  40.7128,
		Latitude:   -74.0060,
		StartDate:  "2024-04-12T00:00:00Z",
		EndDate:    "2024-05-12T00:00:00Z",
	},
	{
		ID:        2,
		BaseModel: models.BaseModel{},
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "mtg.jpg",
				FileExtension: "jpg",
			},
		},
		Name:       SecondTournamentName,
		Location:   "Paris",
		UserID:     4,
		GameID:     2,
		Rounds:     3,
		MaxPlayers: 32,
		Longitude:  48.8566,
		Latitude:   2.3522,
		StartDate:  "2024-08-12T00:00:00Z",
		EndDate:    "2024-09-12T00:00:00Z",
	},
	{
		ID:        3,
		BaseModel: models.BaseModel{},
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "pokemon.jpeg",
				FileExtension: "jpeg",
			},
		},
		Name:       ThirdTournamentName,
		Location:   "London",
		UserID:     5,
		GameID:     3,
		Rounds:     3,
		MaxPlayers: 32,
		Longitude:  51.5074,
		Latitude:   -0.1278,
		StartDate:  "2024-12-12T00:00:00Z",
		EndDate:    "2025-01-12T00:00:00Z",
	},
}

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

	// get the first game
	gameOne := models.Game{}

	db.First(&gameOne, "name = ?", "Magic: The Gathering")

	// create a tournament
	tournament := models.Tournament{
		Name:       FirstTournamentName,
		Location:   "",
		UserID:     uint(1),
		GameID:     gameOne.ID,
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

func registrationsTournamenstMigrations(db *gorm.DB, users *[]models.User) {

	int := 0

	for _, tournament := range tournamentsFixtures {
		db.Create(&tournament)

		// Associate users with the tournament and set the tournament owner
		associateUsersWithTournament(db, tournament, users)
		// Create the first tournament step
		tournamentStep := createTournamentStep(db, tournament.ID, "First step", 1)

		if int == 0 || int == 1 {

			// Generate matches with position for the tournament step
			generateTournamentMatches(db, tournamentStep.ID, tournament.ID)

			// change status of the tournament
			db.Model(&tournament).Update("status", "started")
		}

		int++
	}

}

func createMediaRecord(db *gorm.DB, fileName, fileExtension string) models.Media {
	media := models.Media{
		FileName:      fileName,
		FileExtension: fileExtension,
	}
	db.Create(&media)
	return media
}

func fetchAndAssociateTournamentWithMedia(db *gorm.DB, tournamentName string, media *models.Media) models.Tournament {
	var tournament models.Tournament
	db.First(&tournament, "name = ?", tournamentName)
	tournament.MediaModel.Media = media
	db.Save(&tournament)
	return tournament
}

func createTournamentStep(db *gorm.DB, tournamentID uint, name string, sequence int) models.TournamentStep {
	tournamentStep := models.TournamentStep{
		TournamentID: tournamentID,
		Name:         name,
		Sequence:     sequence,
	}
	db.Create(&tournamentStep)
	return tournamentStep
}

func associateUsersWithTournament(db *gorm.DB, tournament models.Tournament, users *[]models.User) {
	usersPtr := make([]*models.User, len(*users))
	for i := range *users {
		usersPtr[i] = &(*users)[i]
	}
	tournament.Users = usersPtr
	tournament.UserID = (*users)[0].ID
	db.Save(&tournament)
}

func generateTournamentMatches(db *gorm.DB, tournamentStepID, tournamentID uint) {
	tournamentService := services.NewTournamentService(db)
	matchService := services.NewMatchService(db)
	tournamentService.GenerateMatchesWithPosition(tournamentStepID, tournamentID)

	matchsOfTheTournament, _ := matchService.GetTournamentMatches(tournamentID)

	for _, match := range matchsOfTheTournament {
		players1, _, _ := matchService.GetMatchPlayers(match.ID)

		score := models.Score{
			MatchID: match.ID,
			Score:   2,
		}

		matchService.UpdateScore(match.ID, &score, int(players1.ID))
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

func usersMigration(db *gorm.DB) (*[]models.User, error) {
	users := make([]models.User, 10)

	for i := 0; i < 10; i++ {

		user := models.User{
			Username: faker.FirstName(),
			Email:    faker.Email(),
			Password: "$2a$14$FEB9c6k0pEXUZB3txwOFCeurpu/j/wY5StHUykMXkZShMqdZi/Exm", // Replace with a secure password hashing mechanism
			Role:     "user",
		}

		if err := db.Create(&user).Error; err != nil {
			return nil, err
		}
		users[i] = user
	}

	user := models.User{
		Username: "user",
		Email:    faker.Email(),
		Password: "$2a$14$FEB9c6k0pEXUZB3txwOFCeurpu/j/wY5StHUykMXkZShMqdZi/Exm",
		Role:     "user",
	}

	if err := db.Create(&user).Error; err != nil {
		return nil, err
	}

	user2 := models.User{
		Username: "user2",
		Email:    faker.Email(),
		Password: "$2a$14$FEB9c6k0pEXUZB3txwOFCeurpu/j/wY5StHUykMXkZShMqdZi/Exm",
		Role:     "user",
	}

	if err := db.Create(&user2).Error; err != nil {
		return nil, err

	}

	organizer := models.User{
		Username: "organizer",
		Email:    faker.Email(),
		Password: "$2a$14$FEB9c6k0pEXUZB3txwOFCeurpu/j/wY5StHUykMXkZShMqdZi/Exm",
		Role:     "organizer",
	}

	if err := db.Create(&organizer).Error; err != nil {
		return nil, err

	}

	organizer2 := models.User{
		Username: "organizer2",
		Email:    faker.Email(),
		Password: "$2a$14$FEB9c6k0pEXUZB3txwOFCeurpu/j/wY5StHUykMXkZShMqdZi/Exm",
		Role:     "organizer",
	}

	if err := db.Create(&organizer2).Error; err != nil {
		return nil, err

	}

	return &users, nil
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
func guildMigration(db *gorm.DB, users *[]models.User) (*models.Guild, error) {
	media := createMediaRecord(db, "gentle_mates.png", "png")

	err := db.AutoMigrate(&models.Guild{})
	if err != nil {
		fmt.Println(err.Error())
		return nil, err
	}

	guild := models.Guild{
		Name:        "Gentle mates",
		Description: "Guild created for gentlemen and squeezos.",
		MediaModel:  models.MediaModel{Media: &media},
	}

	db.Create(&guild)

	guild.Players = users
	guildAdmins := make([]models.User, 1)
	guildAdmins[0] = (*users)[0]
	guild.Admins = &guildAdmins

	db.Save(&guild)

	return &guild, nil
}
func terminateConnections(defaultDB *gorm.DB, dbName string) error {
	// Terminate other connections to the database
	sql := fmt.Sprintf(`
		SELECT pg_terminate_backend(pg_stat_activity.pid)
		FROM pg_stat_activity
		WHERE pg_stat_activity.datname = '%s'
		  AND pid <> pg_backend_pid();
	`, dbName)

	return defaultDB.Exec(sql).Error
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

	// Connect to the default 'postgres' database
	defaultDSN := fmt.Sprintf("user=%s password=%s dbname=postgres host=%s port=%s sslmode=disable TimeZone=Asia/Shanghai", dbUser, dbPassword, dbHost, dbPort)
	defaultDB, err := gorm.Open(postgres.Open(defaultDSN), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("failed to connect to the default database: %v", err)
	}

	// Terminate other connections to the target database
	err = terminateConnections(defaultDB, dbName)
	if err != nil {
		log.Fatalf("failed to terminate other connections: %v", err)
	}

	// Drop the target database
	err = defaultDB.Exec(fmt.Sprintf("DROP DATABASE IF EXISTS %s", dbName)).Error
	if err != nil {
		log.Fatalf("failed to drop database: %v", err)
	}

	// Recreate the target database
	err = defaultDB.Exec(fmt.Sprintf("CREATE DATABASE %s", dbName)).Error
	if err != nil {
		log.Fatalf("failed to create database: %v", err)
	}

	// Close the connection to the default database
	sqlDB, err := defaultDB.DB()
	if err != nil {
		log.Fatalf("failed to get sqlDB: %v", err)
	}
	sqlDB.Close()

	// Connect to the newly created target database
	dsn := fmt.Sprintf("user=%s password=%s dbname=%s host=%s port=%s sslmode=disable TimeZone=Asia/Shanghai", dbUser, dbPassword, dbName, dbHost, dbPort)
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("failed to connect to the newly created database: %v", err)
	}

	// Now you can proceed with your migrations
	err = db.AutoMigrate(&models.User{})
	err = db.AutoMigrate(&models.TournamentStep{})
	err = db.AutoMigrate(&models.Tag{})
	err = db.AutoMigrate(&models.Tournament{})
	err = db.AutoMigrate(&models.Game{})
	err = db.AutoMigrate(&models.Match{})
	err = db.AutoMigrate(&models.Media{})
	err = db.AutoMigrate(&models.Score{})
	err = db.AutoMigrate(&models.GameScore{})
	err = db.AutoMigrate(&models.Guild{})
	err = db.AutoMigrate(&models.ChatMessage{})

	// Add triggers and functions
	createFunction := `
CREATE OR REPLACE FUNCTION update_game_scores()
RETURNS TRIGGER AS $$
BEGIN
 IF TG_OP = 'UPDATE' AND NEW.score = 2 THEN
  -- Mise à jour du score existant
  UPDATE game_scores
  SET total_score = total_score + NEW.score - OLD.score
  WHERE user_id = NEW.player_id AND game_id = (
   SELECT game_id
   FROM tournaments
   JOIN tournament_steps ON tournament_steps.tournament_id = tournaments.id
   JOIN matches ON matches.tournament_step_id = tournament_steps.id
   WHERE matches.id = NEW.match_id
  );
  UPDATE users
  SET global_score = global_score + NEW.score - OLD.score
  WHERE id = NEW.player_id;
 ELSIF TG_OP = 'INSERT' AND NEW.score = 2 THEN
  -- Vérifier si l'enregistrement existe déjà
  IF EXISTS (
   SELECT 1
   FROM game_scores
   WHERE user_id = NEW.player_id AND game_id = (
    SELECT game_id
    FROM tournaments
    JOIN tournament_steps ON tournament_steps.tournament_id = tournaments.id
    JOIN matches ON matches.tournament_step_id = tournament_steps.id
    WHERE matches.id = NEW.match_id
   )
  ) THEN
   -- Mise à jour de l'enregistrement existant
   UPDATE game_scores
   SET total_score = total_score + NEW.score
   WHERE user_id = NEW.player_id AND game_id = (
    SELECT game_id
    FROM tournaments
    JOIN tournament_steps ON tournament_steps.tournament_id = tournaments.id
    JOIN matches ON matches.tournament_step_id = tournament_steps.id
    WHERE matches.id = NEW.match_id
   );
  ELSE
   -- Insertion d'un nouvel enregistrement
   INSERT INTO game_scores (user_id, game_id, total_score)
   VALUES (NEW.player_id, (
    SELECT game_id
    FROM tournaments
    JOIN tournament_steps ON tournament_steps.tournament_id = tournaments.id
    JOIN matches ON matches.tournament_step_id = tournament_steps.id
    WHERE matches.id = NEW.match_id
   ), NEW.score);
  END IF;
  -- Mettre à jour le global_score
  UPDATE users
  SET global_score = global_score + NEW.score
  WHERE id = NEW.player_id;
 END IF;
 RETURN NEW;
END;
$$ LANGUAGE plpgsql;
	`

	if err := db.Exec(createFunction).Error; err != nil {
		log.Fatalf("failed to create function: %v", err)
	}

	createUpdateTrigger := `
	CREATE TRIGGER update_game_scores_trigger
	AFTER UPDATE ON scores
	FOR EACH ROW
	EXECUTE FUNCTION update_game_scores();
	`

	createInsertTrigger := `
	CREATE TRIGGER insert_game_scores_trigger
	AFTER INSERT ON scores
	FOR EACH ROW
	EXECUTE FUNCTION update_game_scores();
	`

	if err := db.Exec(createUpdateTrigger).Error; err != nil {
		log.Fatalf("failed to create update trigger: %v", err)
	}

	if err := db.Exec(createInsertTrigger).Error; err != nil {
		log.Fatalf("failed to create insert trigger: %v", err)
	}

	log.Println("Triggers created successfully")

	var user models.User

	if user.ID == 0 {
		user = models.User{Username: "admin", Password: "$2a$14$FEB9c6k0pEXUZB3txwOFCeurpu/j/wY5StHUykMXkZShMqdZi/Exm", Email: "test@example.com", Role: "admin"}
		db.Create(&user)
	}
	users, errUsers := usersMigration(db)

	if errUsers != nil {
		log.Fatalf("failed to create users: %v", errUsers)

	}

	db.First(&user, "username = ?", "user")
	_, err = mediaMigration(db)
	_, errGuild := guildMigration(db, users)

	if errGuild != nil {
		log.Fatalf("failed to create guild: %v", errGuild)
	}

	err = insertGamesFixtures(db)
	if err != nil {
		log.Fatalf("failed to insert games fixtures: %v", err)
	}

	registrationsTournamenstMigrations(db, users)

	if err != nil {
		fmt.Println(err.Error())
		return err
	}

	return nil
}
