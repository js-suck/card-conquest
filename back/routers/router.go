package routers

import (
	"authentication-api/handlers"
	"authentication-api/middlewares"
	"authentication-api/models"
	"authentication-api/permissions"
	"authentication-api/services"
	"fmt"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupRouter(db *gorm.DB) *gin.Engine {
	r := gin.Default()
	r.Use(func(c *gin.Context) {

		fmt.Println("Middleware")

		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		c.Writer.Header().Set("Access-Control-Expose-Headers", "Content-Length")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(200)
			return
		}

		c.Next()
	})

	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		c.Writer.Header().Set("Access-Control-Expose-Headers", "Content-Length")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(200)
			return
		}

		c.Next()
	})

	// handlers are like controllers
	authHandler := handlers.NewAuthHandler(services.NewAuthService(db), services.NewUserService(db))
	userHandler := handlers.UserHandler{UserService: services.NewUserService(db), FileService: services.NewFileService(db)}
	tournamentHandler := handlers.NewTournamentHandler(services.NewTournamentService(db), services.NewFileService(db), services.NewMatchService(db))
	tagHandler := handlers.NewTagHandler(services.NewTagService(db))
	gameHandler := handlers.NewGameHandler(services.NewGameService(db))
	uploadFileHandler := handlers.NewUploadHandler(services.NewFileService(db))
	matchHandler := handlers.NewMatchHandler(services.NewMatchService(db))
	guildHandler := handlers.NewGuildHandler(services.NewGuildService(db))
	featureFlagHandler := handlers.NewFeatureFlagHandler(db)

	publicRoutes := r.Group("/api/v1")
	protectedRoutes := r.Group("/api/v1")
	{
		publicRoutes.POST("/login", authHandler.Login)
		publicRoutes.POST("/auth/google", authHandler.RegisterWithGoogle)
	}
	publicRoutes.GET("/images/:filename", func(c *gin.Context) {
		filename := c.Param("filename")
		c.File("./uploads/" + filename)
	})

	publicRoutes.POST("/register", authHandler.Register)

	publicRoutes.GET("/users/verify", authHandler.ConfirmEmail)
	protectedRoutes.GET("/users/ranks", userHandler.GetUsersRanks)
	protectedRoutes.GET("/users", userHandler.GetUsers)
	protectedRoutes.GET("/users/:id/stats", userHandler.GetUserStats)

	protectedRoutes.GET("/tournaments/rankings", tournamentHandler.GetTournamentRankings)
	protectedRoutes.GET("/tournaments", tournamentHandler.GetTournaments)

	protectedRoutes.GET("/tags", tagHandler.GetAllTags)

	protectedRoutes.GET("/guilds", guildHandler.GetAllGuilds)
	protectedRoutes.GET("/guilds/:id", guildHandler.GetGuild)

	protectedRoutes.GET("/users/:id", userHandler.GetUser())
	protectedRoutes.GET("/guilds/user/:userId", guildHandler.GetGuildsByUserId)

	protectedRoutes.GET("/tournaments/:id", tournamentHandler.GetTournament)
	protectedRoutes.GET("/tournaments/:id/matches", tournamentHandler.GetTournamentMatches)
	protectedRoutes.GET(("/games"), gameHandler.GetAllGames)
	protectedRoutes.GET(("/games/user/:userID/rankings"), gameHandler.GetUserGameRankings)
	protectedRoutes.GET(("/games/:id/ranks"), gameHandler.GetGameRanks)
	protectedRoutes.GET("/games/:id", gameHandler.GetGameByID)

	protectedRoutes.Use(middlewares.AuthenticationMiddleware())
	{
		publicRoutes.GET("/feature/:name", featureFlagHandler.GetFeatureFlag)
		publicRoutes.POST("/feature/:name", featureFlagHandler.SetFeatureFlag)
		publicRoutes.GET("/feature", featureFlagHandler.GetFeatureFlags)
		publicRoutes.POST("/images", uploadFileHandler.UploadImage)

		protectedRoutes.POST("/users", permissions.PermissionMiddleware(permissions.PermissionCreateUser), userHandler.PostUser)
		protectedRoutes.PUT("/users/:id", middlewares.OwnerMiddleware("user", &models.User{}), permissions.PermissionMiddleware(permissions.PermissionUpdateUser), userHandler.UpdateUser)
		protectedRoutes.DELETE("/users/:id", middlewares.OwnerMiddleware("user", &models.User{}), permissions.PermissionMiddleware(permissions.PermissionDeleteUser), userHandler.DeleteUser)
		protectedRoutes.POST("/users/:id/upload/picture", middlewares.OwnerMiddleware("user", &models.User{}), permissions.PermissionMiddleware(permissions.PermissionUpdateUser), userHandler.UploadPicture)
		protectedRoutes.POST("/users/subscriptions/:userID/tournaments/:tournamentID/subscribe", tournamentHandler.SubscribeToTournament)
		protectedRoutes.POST("/users/subscriptions/:userID/tournaments/:tournamentID/unsubscribe", tournamentHandler.UnsubscribeFromTournament)
		protectedRoutes.GET("/users/subscriptions/:userID/tournaments", tournamentHandler.GetSubscribedTournaments)

		protectedRoutes.POST("/tournaments", permissions.PermissionMiddleware(permissions.PermissionCreateTournament), tournamentHandler.CreateTournament)
		protectedRoutes.PUT("/tournaments/:id", permissions.PermissionMiddleware(permissions.PermissionUpdateTournament), middlewares.OwnerMiddleware("tournament", models.Tournament{}), tournamentHandler.UpdateTournament)
		protectedRoutes.DELETE("/tournaments/:id", permissions.PermissionMiddleware(permissions.PermissionDeleteTournament), tournamentHandler.DeleteTournament)

		protectedRoutes.POST("/tournaments/:id/start", tournamentHandler.StartTournament)
		protectedRoutes.POST("/tournaments/:id/register/:userID", tournamentHandler.RegisterUser)
		protectedRoutes.POST("/tournaments/:id/generate-matches", tournamentHandler.GenerateMatches)

		//protectedRoutes.POST("/matches/:id/finish", tournamentHandler.FinishMatch)
		protectedRoutes.POST("/matchs/update/score", permissions.PermissionMiddleware(permissions.PermissionUpdateMatch), matchHandler.UpdateScore)

		protectedRoutes.PUT("/matchs/:id", permissions.PermissionMiddleware(permissions.PermissionUpdateMatch), matchHandler.UpdateMatch)
		protectedRoutes.PUT("/bracket/matchs/:id", permissions.PermissionMiddleware(permissions.PermissionUpdateMatch), matchHandler.UpdateBracketMatch)
		protectedRoutes.GET("/matchs/between-users", matchHandler.GetMatchesBetweenUsers)
		protectedRoutes.GET(("/matchs"), matchHandler.GetAllMatchs)
		protectedRoutes.GET(("/matchs/:id"), matchHandler.GetMatch)

		protectedRoutes.POST("/games", gameHandler.CreateGame)
		protectedRoutes.PUT("/games/:id", gameHandler.UpdateGame)
		protectedRoutes.DELETE("/games/:id", gameHandler.DeleteGame)

		protectedRoutes.POST("/tags", permissions.PermissionMiddleware(permissions.PermissionCreateTag), tagHandler.CreateTag)
		protectedRoutes.PUT("/tags/:id", permissions.PermissionMiddleware(permissions.PermissionUpdateTag), tagHandler.UpdateTag)
		protectedRoutes.DELETE("/tags/:id", permissions.PermissionMiddleware(permissions.PermissionDeleteTags), tagHandler.DeleteTag)

		protectedRoutes.POST("/guilds", permissions.PermissionMiddleware(permissions.PermissionCreateGuild), guildHandler.CreateGuild)
		protectedRoutes.PUT("/guilds/:id", permissions.PermissionMiddleware(permissions.PermissionUpdateGuild), guildHandler.UpdateGuild)
		protectedRoutes.DELETE("/guilds/:id", permissions.PermissionMiddleware(permissions.PermissionDeleteGuild), guildHandler.DeleteGuild)
		protectedRoutes.DELETE("/guilds/:id/users/:userID", permissions.PermissionMiddleware(permissions.PermissionLeaveGuild), guildHandler.RemoveUserFromGuild)
		protectedRoutes.POST("/guilds/:id/users/:userID", permissions.PermissionMiddleware(permissions.PermissionJoinGuild), guildHandler.AddUserToGuild)
		//protectedRoutes.DELETE("/guilds/:id/users/:userID", guildHandler.RemoveUserFromGuild)

	}

	return r
}
