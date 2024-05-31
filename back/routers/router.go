package routers

import (
	"authentication-api/handlers"
	"authentication-api/middlewares"
	"authentication-api/models"
	"authentication-api/permissions"
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

	protectedRoutes.Use(middlewares.AuthenticationMiddleware())
	{
		publicRoutes.POST("/images", uploadFileHandler.UploadImage)

		publicRoutes.POST("/register", authHandler.Register)
		publicRoutes.GET("/users/verify", authHandler.ConfirmEmail)
		protectedRoutes.GET("/users/:id", permissions.PermissionMiddleware(permissions.PermissionReadeUser), middlewares.OwnerMiddleware("user", &models.User{}), userHandler.GetUser())
		protectedRoutes.GET("/users", permissions.PermissionMiddleware(permissions.PermissionReadeUser), userHandler.GetUsers)
		protectedRoutes.GET("/users/ranks", permissions.PermissionMiddleware(permissions.PermissionReadeUser), userHandler.GetUsersRanks)
		protectedRoutes.GET("/users/:id/stats", permissions.PermissionMiddleware(permissions.PermissionReadeUser), userHandler.GetUserStats)
		protectedRoutes.POST("/users", permissions.PermissionMiddleware(permissions.PermissionCreateUser), userHandler.PostUser)
		protectedRoutes.PUT("/users/:id", middlewares.OwnerMiddleware("user", &models.User{}), permissions.PermissionMiddleware(permissions.PermissionUpdateUser), userHandler.UpdateUser)
		protectedRoutes.DELETE("/users/:id", middlewares.OwnerMiddleware("user", &models.User{}), permissions.PermissionMiddleware(permissions.PermissionDeleteUser), userHandler.DeleteUser)
		protectedRoutes.POST("/users/:id/upload/picture", middlewares.OwnerMiddleware("user", &models.User{}), permissions.PermissionMiddleware(permissions.PermissionUpdateUser), userHandler.UploadPicture)

		protectedRoutes.POST("/tournaments", tournamentHandler.CreateTournament)
		protectedRoutes.GET("/tournaments/rankings", tournamentHandler.GetTournamentRankings)
		protectedRoutes.GET("/tournaments", tournamentHandler.GetTournaments)
		protectedRoutes.POST("/tournaments/:id/start", tournamentHandler.StartTournament)
		protectedRoutes.GET("/tournaments/:id", tournamentHandler.GetTournament)
		protectedRoutes.POST("/tournaments/:id/register/:userID", tournamentHandler.RegisterUser)
		protectedRoutes.POST("/tournaments/:id/generate-matches", tournamentHandler.GenerateMatches)
		protectedRoutes.GET("/tournaments/:id/matches", tournamentHandler.GetTournamentMatches)

		//protectedRoutes.POST("/matches/:id/finish", tournamentHandler.FinishMatch)
		protectedRoutes.POST("/matches/update/score", matchHandler.UpdateScore)
		protectedRoutes.GET("/matchs/between-users", matchHandler.GetMatchesBetweenUsers)

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
