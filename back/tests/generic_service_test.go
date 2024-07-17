package test

import (
	"authentication-api/db"
	"authentication-api/models"
	service "authentication-api/services"
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

var initialUser = models.User{}

func TestCreateModel(t *testing.T) {
	user := models.User{Username: "user202", Password: "password", Role: "user", Email: "user202@gmail.com"}

	service := service.NewGenericService(db.DB, &models.User{})
	err := service.Create(&user)

	if err != nil {
		fmt.Print(err)
	}

	assert.Nil(t, err)
}

func TestCreateUserModel(t *testing.T) {
	user := models.User{Username: "TestCreateUserModel", Password: "password", Email: fmt.Sprintf("TestCreateUserModel@gmail.com")}

	service := service.NewUserService(db.DB)
	err := service.Create(&user)

	if err != nil {
		fmt.Print(err)
	}

	assert.Nil(t, err)
}

func TestShouldNotCreateModelWithExistingModel(t *testing.T) {
	user := models.User{Username: "user", Password: "password"}

	genericService := service.NewGenericService(db.DB, &models.User{})
	err := genericService.Create(&user)

	assert.NotNil(t, err)
}

//func TestShouldUpdateModel(t *testing.T) {
//	db := initDB()
//	updatedUser := models.User{ID: 22}
//	var wantDb = map[string]interface{}{
//		"Username": "losdsdsdsdsl",
//	}
//
//	genericService := service.NewGenericService(db, models.User{})
//	err := genericService.UpdateById(&updatedUser, wantDb)
//	if err != nil {
//		return
//	}
//
//	_, err = genericService.Get(&updatedUser)
//
//	assert.Equal(t, updatedUser.ID, uint(22))
//	assert.Equal(t, wantDb["Username"], updatedUser.Username)
//
//}
