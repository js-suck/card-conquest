package db

import (
	"authentication-api/models"
	"authentication-api/services"
	"fmt"
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

func registrationsTournamentMigrations(db *gorm.DB, users *[]models.User) {
	// Create media record
	media := createMediaRecord(db, "yugiho.webp", "webp")

	// Fetch the first tournament and associate it with the media
	tournament := fetchAndAssociateTournamentWithMedia(db, FirstTournamentName, &media)

	// Create the first tournament step
	tournamentStep := createTournamentStep(db, tournament.ID, "First step", 1)

	// Associate users with the tournament and set the tournament owner
	associateUsersWithTournament(db, tournament, users)

	// Generate matches with position for the tournament step
	generateTournamentMatches(db, tournamentStep.ID, tournament.ID)
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
	tournamentService.GenerateMatchesWithPosition(tournamentStepID, tournamentID)
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
			Username: fmt.Sprintf("Test%d", i),
			Password: "$2a$14$FEB9c6k0pEXUZB3txwOFCeurpu/j/wY5StHUykMXkZShMqdZi/Exm",
			Email:    fmt.Sprintf("Test%d•gmail.com", i),
			Role:     "user",
		}

		db.Create(&user)
		users[i] = user
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

	var user models.User

	if user.ID == 0 {
		user = models.User{Username: "user", Password: "$2a$14$FEB9c6k0pEXUZB3txwOFCeurpu/j/wY5StHUykMXkZShMqdZi/Exm", Email: "test@example.com", Role: "admin"}
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

	_, err = tournamentMigration(db, &GamesFixtures[1])

	registrationsTournamentMigrations(db, users)

	if err != nil {
		fmt.Println(err.Error())
		return err
	}

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

	return nil
}
