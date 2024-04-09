package routers

import (
	"authentication-api/handlers"
	"authentication-api/middlewares"
	"authentication-api/services"
	"fmt"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupRouter(db *gorm.DB) *gin.Engine {
	r := gin.Default()

	// handlers are like controllers
	authHandler := handlers.AuthHandler{AuthService: services.NewAuthService(db)}
	userHandler := handlers.UserHandler{UserService: services.NewUserService(db)}

	publicRoutes := r.Group("/api/v1")
	protectedRoutes := r.Group("/api/v1")
	{
		publicRoutes.POST("/login", authHandler.Login)
		publicRoutes.POST("/register", handlers.Register)
	}

	protectedRoutes.Use(middlewares.AuthenticationMiddleware(), middlewares.PermissionMiddleware(db))
	{
		fmt.Println("Protected routes")
		protectedRoutes.GET("/user/:id", userHandler.GetUser())
		protectedRoutes.GET("/users", userHandler.GetUsers)
		protectedRoutes.POST("/users", userHandler.PostUser)
		protectedRoutes.PUT("/users/:id", userHandler.UpdateUser)
		protectedRoutes.DELETE("/users/:id", userHandler.DeleteUser)
	}

	return r
}
