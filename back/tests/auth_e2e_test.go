package handlers_test

import (
	"authentication-api/handlers"
	"authentication-api/models"
	"authentication-api/services"
	"bytes"
	"encoding/json"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"net/http"
	"net/http/httptest"
	"testing"
)

func initApp() *gin.Engine {
	db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})

	if err != nil {
		panic("Failed to connect to database")
	}

	//@TODO add default user if not exists with username: user, password: password
	var user models.User
	db.First(&user, "username = ?", "user")
	if user.ID == 0 {
		user = models.User{Username: "user", Password: "password"}
		db.Create(&user)
	}
	authService := services.NewAuthService(db)
	handler := handlers.AuthHandler{AuthService: authService}
	router := gin.Default()
	router.POST("/login", handler.Login)
	router.POST("/register", handlers.Register)
	return router

}

func TestLoginWithValidCredentials(t *testing.T) {
	router := initApp()
	user := models.User{Username: "user", Password: "password"}
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
	router := gin.Default()
	router.POST("/register", handlers.Register)

	user := models.User{Username: "newuser", Password: "newpassword"}
	body, _ := json.Marshal(user)
	req, _ := http.NewRequest(http.MethodPost, "/register", bytes.NewBuffer(body))
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusCreated, resp.Code)
	assert.Contains(t, resp.Body.String(), "User registered successfully")
}

func TestRegisterWithInvalidData(t *testing.T) {
	router := gin.Default()
	router.POST("/register", handlers.Register)

	body := bytes.NewBuffer([]byte(`{"invalid": "data"}`))
	req, _ := http.NewRequest(http.MethodPost, "/register", body)
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusBadRequest, resp.Code)
	assert.Contains(t, resp.Body.String(), "Invalid data")
}
