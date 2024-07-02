package main

import (
	dbService "authentication-api/db"
	docs "authentication-api/docs"
	feature_flag "authentication-api/feature-flag"
	grpcServices "authentication-api/grpc"
	"authentication-api/models"
	authentication_api "authentication-api/pb/github.com/lailacha/authentication-api"
	"authentication-api/routers"
	"fmt"
	"github.com/joho/godotenv"
	"github.com/sirupsen/logrus"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"google.golang.org/grpc"
	"log"
	"net"
	"os"
)

import _ "github.com/swaggo/gin-swagger" // gin-swagger middleware
import _ "github.com/swaggo/files"       // swagger embed files

// @title           Swagger Example API
// @version         1.0
// @description     This is a sample server celler server.
// @termsOfService  http://swagger.io/terms/

// @contact.name   API Support
// @contact.url    http://www.swagger.io/support
// @contact.email  support@swagger.io

// @license.name  Apache 2.0
// @license.url   http://www.apache.org/licenses/LICENSE-2.0.html

// @host      localhost:8080
// @BasePath  /api/v1

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @externalDocs.description  OpenAPI
// @externalDocs.url          https://swagger.io/resources/open-api/
func main() {
	// Initialize logging
	logrus.SetFormatter(&logrus.JSONFormatter{})

	//firebaseClient, errF := firebase.NewFirebaseClient("./firebase/privateKey.json")
	//if errF != nil {
	//	log.Fatalf("Failed to initialize Firebase: %v", errF)
	//}
	//
	//// Example: Send a notification
	//token := "cxv_VendS7-FtM7jfzpeYi:APA91bGvkbXDDnPHb6jzSpFz6aArQhAzSJYW0F1cX4e1MMgKwX01sOvXdHS9TeiAOeV0L2RowrmEMtIPnFs0p4aVH4gRneq7WTTafBNuVzhyMStuMjmA3HDHGrYm-284aCNP8UxQe8mL"
	//title := "Test Notification"
	//body := "This is a test notification"
	//response, err := firebaseClient.SendNotification(token, title, body)
	//if err != nil {
	//	log.Fatalf("Failed to send notification: %v", err)
	//}
	//fmt.Printf("Successfully sent notification: %s\n", response)

	logFile, err := os.OpenFile("/var/log/myapp.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		logrus.Error("Failed to open log file: ", err)
	} else {
		defer logFile.Close()
		logrus.SetOutput(logFile)
	}

	err = godotenv.Load(".env")
	if err != nil {
		logrus.Fatalf("Erreur lors du chargement du fichier .env: %v", err)
	}

	DB, err := dbService.InitDB()
	if err != nil {
		logrus.Fatalf("Failed to initialize database: %v", err)
	}

	err = DB.AutoMigrate(models.User{}, models.Tournament{}, models.Match{}, models.Score{}, models.TournamentStep{}, models.Media{}, models.TournamentStep{}, models.GameScore{}, models.Guild{}, models.ChatMessage{})
	if err != nil {
		logrus.Fatalf("Failed to migrate database: %v", err)
		return
	}

	if DB == nil {
		return
	}

	if err != nil {
		logrus.Fatalf("Failed to connect to database: %v", err)
		return
	}

	if len(os.Args) > 1 && os.Args[1] == "migrate" {
		logrus.Info("Migrating the database...")
		err := dbService.MigrateDatabase()
		if err != nil {
			logrus.Fatalf("Database migration failed: %v", err)
		}

		os.Exit(0)

	} else {
		logrus.Info("Aucun argument fourni.")
	}

	if err != nil {
		logrus.Panic("failed to connect database")
	}

	flags, err := feature_flag.LoadConfig("configuration.yaml")
	if err != nil {
		log.Fatalf("Erreur lors du chargement des flags de fonctionnalité: %v", err)
	}

	fmt.Println("Feature Flags:", flags)

	docs.SwaggerInfo.BasePath = "/api/v1"
	go func() {
		lis, err := net.Listen("tcp", ":50051")
		if err != nil {
			logrus.Fatalf("Failed to listen: %v", err)
		}

		s := grpc.NewServer()

		matchServiceServer := grpcServices.NewMatchServer()
		chatServer := grpcServices.NewChatServer()
		tournamentServiceServer := grpcServices.NewTournamentServer()

		authentication_api.RegisterTournamentServiceServer(s, tournamentServiceServer)
		authentication_api.RegisterChatServiceServer(s, chatServer)
		authentication_api.RegisterMatchServiceServer(s, matchServiceServer)

		logrus.Info("Server is running on port 50051")
		if err := s.Serve(lis); err != nil {
			logrus.Fatalf("Failed to serve: %v", err)
		}
	}()

	r := routers.SetupRouter(DB)
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	if err := r.Run(":8080"); err != nil {
		logrus.Fatalf("Failed to run server: %v", err)
	}
}
