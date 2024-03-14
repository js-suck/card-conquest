package routers

import (
	"authentication-api/handlers"
	"authentication-api/middlewares"
	"github.com/gin-gonic/gin"
)

func SetupRouter() *gin.Engine {
	r := gin.Default()

	publicRoutes := r.Group("/api")
	{
		publicRoutes.POST("/login", handlers.Login)
		publicRoutes.POST("/register", handlers.Register)
	}

	protectedRoutes := r.Group("/protected")
	protectedRoutes.Use(middlewares.AuthenticationMiddleware())
	{
		// Protected routes
	}

	return r
}
