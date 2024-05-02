package handlers_test

import (
	"authentication-api/handlers"
	"authentication-api/models"
	"authentication-api/services"
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"math/rand"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"
	"time"
)

func initApp() *gin.Engine {
	db, err := gorm.Open(sqlite.Open("./back/ddcard.db"), &gorm.Config{})

	if err != nil {
		panic("Failed to connect to database")
	}

	//@TODO add default user if not exists with username: user, password: password
	var user models.User
	err = db.AutoMigrate(&models.User{})
	if err != nil {
		return nil
	}
	db.First(&user, "username = ?", "user")
	if user.ID == 0 {
		user = models.User{Username: "user", Password: "password", Email: "test@user.gmail.com"}
		db.Create(&user)
	}
	authService := services.NewAuthService(db)
	userService := services.NewUserService(db)
	handler := handlers.AuthHandler{AuthService: authService, UserService: userService}
	router := gin.Default()
	router.POST("/login", handler.Login)
	router.POST("/register", handler.Register)
	return router

}

func TestLoginWithValidCredentials(t *testing.T) {
	router := initApp()
	user := models.User{Username: "userezfzeezfzeezzef", Password: "password"}
	body, _ := json.Marshal(user)
	req, _ := http.NewRequest(http.MethodPost, "/login", bytes.NewBuffer(body))
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)
	assert.Contains(t, resp.Body.String(), "token")
}

func TestLoginWithInvalidCredentials(t *testing.T) {
	router := initApp()
	user := models.User{Username: "wrong", Password: "wrong"}
	body, _ := json.Marshal(user)
	req, _ := http.NewRequest(http.MethodPost, "/login", bytes.NewBuffer(body))
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusUnauthorized, resp.Code)
	assert.Contains(t, resp.Body.String(), "Invalid credentials")
}

func TestRegisterWithValidData(t *testing.T) {
	router := initApp()
	rand.Seed(time.Now().UnixNano())

	randomNumber := rand.Intn(1000) // adjust the range as needed

	randomNumberStr := strconv.Itoa(randomNumber)

	user := models.User{
		Username: "test" + randomNumberStr,
		Password: "TEST1234!@#$",
		Email:    "test" + randomNumberStr + "@example.com",
	}

	body, _ := json.Marshal(user)
	req, _ := http.NewRequest(http.MethodPost, "/register", bytes.NewBuffer(body))
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusCreated, resp.Code)
}

func TestRegisterWithInvalidData(t *testing.T) {
	router := initApp()

	body := bytes.NewBuffer([]byte(`{"invalid": "data"}`))
	req, _ := http.NewRequest(http.MethodPost, "/register", body)
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusBadRequest, resp.Code)
}

func TestSendSenderEmail(t *testing.T) {
	user := models.User{Username: "user", Password: "password", Email: "mats2@live.fr"}
	db := initDB()

	service := services.NewAuthService(db)
	err := service.SendConfirmationEmail(user.Email, user.Username, user.VerificationToken)

	if err != nil {
		fmt.Print(err)
	}

	assert.Nil(t, err)

}
