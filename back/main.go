package main

import (
	dbService "authentication-api/db"
	docs "authentication-api/docs"
	grpcTounrnament "authentication-api/grpc"
	authentication_api "authentication-api/pb/github.com/lailacha/authentication-api"
	"authentication-api/routers"
	"fmt"
	"github.com/joho/godotenv"
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
	err := godotenv.Load(".env")
	if err != nil {
		log.Fatalf("Erreur lors du chargement du fichier .env: %v", err)
	}

	DB, err := dbService.InitDB()

	if DB == nil {
		return
	}

	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
		return
	}

	if len(os.Args) > 1 && os.Args[1] == "migrate" {
		fmt.Println("Migrating the database...")
		//// Migrate the schema
		err := dbService.MigrateDatabase()
		if err != nil {
			return
		}

		os.Exit(0)

	} else {
		fmt.Println("Aucun argument fourni.")
	}

	if err != nil {
		panic("failed to connect database")
	}

	docs.SwaggerInfo.BasePath = "/api/v1"

	go func() {
		lis, err := net.Listen("tcp", ":50051")
		if err != nil {
			log.Fatalf("Failed to listen: %v", err)
		}
		s := grpc.NewServer()
		authentication_api.RegisterTournamentServiceServer(s, grpcTounrnament.NewServer())
		log.Println("Server is running on port 50051")
		if err := s.Serve(lis); err != nil {
			log.Fatalf("Failed to serve: %v", err)
		}
	}()

	r := routers.SetupRouter(DB)
	// !!!! http://localhost:8080/swagger/index.html to see it !!!!
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	r.Run(":8080")

}
