package main

import (
	dbService "authentication-api/db"
	docs "authentication-api/docs"
	authentication_api "authentication-api/pb/github.com/lailacha/authentication-api"
	"authentication-api/routers"
	"fmt"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"google.golang.org/grpc"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"log"
	"net"
	"os"
	"time"
)
import _ "github.com/swaggo/gin-swagger" // gin-swagger middleware
import _ "github.com/swaggo/files"       // swagger embed files

type server struct {
	authentication_api.UnimplementedMatchServiceServer
}

func (s *server) SubscribeMatchUpdates(req *authentication_api.MatchRequest, stream authentication_api.MatchService_SubscribeMatchUpdatesServer) error {
	log.Printf("Received request for match ID: %v", req.MatchId)
	for {
		// Logique pour envoyer des mises à jour
		update := &authentication_api.MatchResponse{
			MatchId: req.MatchId,
			Status:  "ongoing", // exemple de statut
			Detail:  fmt.Sprintf("Match %v is ongoing at %v", req.MatchId, time.Now().Format(time.RFC3339)),
		}
		if err := stream.Send(update); err != nil {
			return err
		}
		// attendre ou générer des mises à jour

		fmt.Println("please send update")
		time.Sleep(1 * time.Minute) // Attend une minute

	}
}

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

	newLogger := logger.New(
		log.New(os.Stdout, "\r\n", log.LstdFlags),
		logger.Config{
			SlowThreshold: time.Second,
			LogLevel:      logger.Info,
			Colorful:      true,
		},
	)

	db, err := gorm.Open(sqlite.Open("./back/card.db?_foreign_keys=on"), &gorm.Config{
		Logger: newLogger,
	})

	if err != nil {
		panic("failed to connect database")
	}

	docs.SwaggerInfo.BasePath = "/api/v1"

	if len(os.Args) > 1 && os.Args[1] == "migrate" {
		fmt.Println("Migrating the database...")
		//// Migrate the schema
		err := dbService.MigrateDatabase(db)
		if err != nil {
			return
		}

	} else {
		fmt.Println("Aucun argument fourni.")
	}
	go func() {
		lis, err := net.Listen("tcp", ":50051")
		if err != nil {
			log.Fatalf("Failed to listen: %v", err)
		}
		s := grpc.NewServer()
		authentication_api.RegisterMatchServiceServer(s, &server{})
		log.Println("Server is running on port 50051")
		if err := s.Serve(lis); err != nil {
			log.Fatalf("Failed to serve: %v", err)
		}
	}()

	r := routers.SetupRouter(db)
	// !!!! http://localhost:8080/swagger/index.html to see it !!!!
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	r.Run(":8080")

}
