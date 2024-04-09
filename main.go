package main

import (
	docs "authentication-api/docs"
	"authentication-api/models"
	"authentication-api/routers"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)
import _ "github.com/swaggo/gin-swagger" // gin-swagger middleware
import _ "github.com/swaggo/files"       // swagger embed files

type Product struct {
	gorm.Model
	Code  string
	Price uint
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
	db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	docs.SwaggerInfo.BasePath = "/api/v1"
	//// Migrate the schema
	err = db.AutoMigrate(&models.User{})
	if err != nil {
		return
	}

	//@TODO add default user if not exists with username: user, password: password
	var user models.User
	db.First(&user, "username = ?", "user")
	if user.ID == 0 {
		user = models.User{Username: "user", Password: "password"}
		db.Create(&user)
	}

	r := routers.SetupRouter(db)
	// !!!! http://localhost:8080/swagger/index.html to see it !!!!
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	r.Run(":8080")

}
