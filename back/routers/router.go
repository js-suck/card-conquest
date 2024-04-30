package routers

import (
	"authentication-api/handlers"
	"authentication-api/middlewares"
	"authentication-api/services"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupRouter(db *gorm.DB) *gin.Engine {
	r := gin.Default()

	// handlers are like controllers in MVC
	authHandler := handlers.NewAuthHandler(services.NewAuthService(db), services.NewUserService(db))
	userHandler := handlers.UserHandler{UserService: services.NewUserService(db), FileService: services.NewFileService(db)}
	tournamentHandler := handlers.NewTournamentHandler(services.NewTournamentService(db))
	gameHandler := handlers.NewGameHandler(services.NewGameService(db))
	uploadFileHandler := handlers.NewUploadHandler(services.NewFileService(db))

	publicRoutes := r.Group("/api/v1")
	protectedRoutes := r.Group("/api/v1")
	{
		publicRoutes.POST("/login", authHandler.Login)
	}
	publicRoutes.GET("/images/:filename", func(c *gin.Context) {
		filename := c.Param("filename")
		c.File("./uploads/" + filename)
	})

	protectedRoutes.Use(middlewares.AuthenticationMiddleware(), middlewares.PermissionMiddleware(db))
	{
		publicRoutes.POST("/images", uploadFileHandler.UploadImage)

		publicRoutes.POST("/register", authHandler.Register)
		publicRoutes.GET("/users/verify", authHandler.ConfirmEmail)
		protectedRoutes.GET("/users/:id", userHandler.GetUser())
		protectedRoutes.GET("/users", userHandler.GetUsers)
		protectedRoutes.POST("/users", userHandler.PostUser)
		protectedRoutes.PUT("/users/:id", userHandler.UpdateUser)
		protectedRoutes.DELETE("/users/:id", userHandler.DeleteUser)
		protectedRoutes.POST("/users/:id/upload/picture", userHandler.UploadPicture)

		protectedRoutes.POST("/tournaments", tournamentHandler.CreateTournament)
		protectedRoutes.GET("/tournaments", tournamentHandler.GetTournaments)
		protectedRoutes.GET("/tournaments/:id", tournamentHandler.GetTournament)
		protectedRoutes.POST("/tournaments/:id/register/:userID", tournamentHandler.RegisterUser)
		protectedRoutes.POST("/tournaments/:id/generate-matches", tournamentHandler.GenerateMatches)

		protectedRoutes.POST("/matches/:id/finish", tournamentHandler.FinishMatch)

		protectedRoutes.GET(("/games"), gameHandler.GetAllGames)

	}

	return r
}
