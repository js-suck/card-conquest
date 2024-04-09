package handlers_test

import (
	"authentication-api/models"
	service "authentication-api/services"
	"fmt"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"testing"
)

var initialUser = models.User{}

func initDB() *gorm.DB {
	db, err := gorm.Open(sqlite.Open("test2.db"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}

	db.AutoMigrate(&models.User{})

	return db
}

func TestCreateModel(t *testing.T) {
	user := models.User{Username: "user", Password: "password"}
	db := initDB()

	service := service.NewGenericService(db, models.User{})
	err := service.Create(&user)

	if err != nil {
		fmt.Print(err)
	}

	assert.Nil(t, err)
}

func TestCreateUserModel(t *testing.T) {
	user := models.User{Username: "user", Password: "password"}
	db := initDB()

	service := service.NewUserService(db)
	err := service.Create(&user)

	if err != nil {
		fmt.Print(err)
	}

	assert.Nil(t, err)
}

func TestShouldNotCreateModelWithExistingModel(t *testing.T) {
	user := models.User{Username: "existingUser", Password: "password"}
	db := initDB()

	genericService := service.NewGenericService(db, models.User{})
	err := genericService.Create(&user)

	assert.Nil(t, err)

	err = genericService.Create(&user)
	assert.NotNil(t, err)
}

func TestShouldUpdateModel(t *testing.T) {
	db := initDB()
	updatedUser := models.User{ID: 22}
	var wantDb = map[string]interface{}{
		"Username": "losdsdsdsdsl",
	}

	genericService := service.NewGenericService(db, models.User{})
	err := genericService.UpdateById(&updatedUser, wantDb)
	if err != nil {
		return
	}

	_, err = genericService.Get(&updatedUser)

	assert.Equal(t, updatedUser.ID, uint(22))
	assert.Equal(t, wantDb["Username"], updatedUser.Username)

}

func Test(t *testing.T) {
	db := initDB()

	newUser := models.User{Username: "zzz", Password: "test"}

	userService := service.NewUserService(db)
	userService.Create(newUser)

}
