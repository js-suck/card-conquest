package handlers_test

import (
	"authentication-api/handlers"
	"authentication-api/models"
	"bytes"
	"encoding/json"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestLoginWithValidCredentials(t *testing.T) {
	router := gin.Default()
	router.POST("/login", handlers.Login)

	user := models.User{Username: "user", Password: "password"}
	body, _ := json.Marshal(user)
	req, _ := http.NewRequest(http.MethodPost, "/login", bytes.NewBuffer(body))
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)
	assert.Contains(t, resp.Body.String(), "token")
}

func TestLoginWithInvalidCredentials(t *testing.T) {
	router := gin.Default()
	router.POST("/login", handlers.Login)

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
