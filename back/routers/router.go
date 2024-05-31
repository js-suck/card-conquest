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

	// handlers are like controllers
	authHandler := handlers.NewAuthHandler(services.NewAuthService(db), services.NewUserService(db))
	userHandler := handlers.UserHandler{UserService: services.NewUserService(db), FileService: services.NewFileService(db)}
	tournamentHandler := handlers.NewTournamentHandler(services.NewTournamentService(db), services.NewFileService(db), services.NewMatchService(db))
	tagHandler := handlers.NewTagHandler(services.NewTagService(db))
	gameHandler := handlers.NewGameHandler(services.NewGameService(db))
	uploadFileHandler := handlers.NewUploadHandler(services.NewFileService(db))
	matchHandler := handlers.NewMatchHandler(services.NewMatchService(db))

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
		protectedRoutes.GET("/tournaments/rankings", tournamentHandler.GetRankings)
		protectedRoutes.GET("/tournaments", tournamentHandler.GetTournaments)
		protectedRoutes.POST("/tournaments/:id/start", tournamentHandler.StartTournament)
		protectedRoutes.GET("/tournaments/:id", tournamentHandler.GetTournament)
		protectedRoutes.POST("/tournaments/:id/register/:userID", tournamentHandler.RegisterUser)
		protectedRoutes.POST("/tournaments/:id/generate-matches", tournamentHandler.GenerateMatches)
		protectedRoutes.GET("/tournaments/:id/matches", tournamentHandler.GetTournamentMatches)

		//protectedRoutes.POST("/matches/:id/finish", tournamentHandler.FinishMatch)
		protectedRoutes.POST("/matches/update/score", matchHandler.UpdateScore)

		protectedRoutes.GET(("/games"), gameHandler.GetAllGames)
		protectedRoutes.GET(("/games/:userID/rankings"), gameHandler.GetUserGameRankings)

		protectedRoutes.GET(("/matchs"), matchHandler.GetAllMatchs)
		protectedRoutes.GET(("/matchs/:id"), matchHandler.GetMatch)
		protectedRoutes.PUT(("/matchs/:id"), matchHandler.UpdateMatch)
		
		protectedRoutes.GET("/tags", tagHandler.GetAllTags)
		protectedRoutes.POST("/tags", tagHandler.CreateTag)

	}

	return r
}
