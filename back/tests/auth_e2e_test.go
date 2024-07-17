package test

import (
	"authentication-api/db"
	"authentication-api/models"
	"authentication-api/routers"
	"authentication-api/services"
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"math/rand"
	"net/http"
	"net/http/httptest"
	"os"
	"strconv"
	"testing"
	"time"
)

var router *gin.Engine
var TokenAdmin string
var TokenUser1 string
var TokenUser2 string
var TokenOrganizer string
var TokenOrganizer2 string

var Organizer1 models.User
var Organizer2 models.User
var Admin models.User
var User1 models.User
var User2 models.User

var PasswordHash = "$2a$14$FEB9c6k0pEXUZB3txwOFCeurpu/j/wY5StHUykMXkZShMqdZi/Exm"

func CreateUserFixtures() {

	// Create an user
	user := models.User{Username: "user1", Password: PasswordHash, Role: "user", Email: "Test11@gmail.com"}

	db.DB.Create(&user)

	user2 := models.User{Username: "user2", Password: PasswordHash, Role: "user", Email: "Test121@gmail.com"}

	db.DB.Create(&user2)

	// Create an organizer
	organizer := models.User{Username: "organizer1Test", Password: PasswordHash, Role: "organizer", Email: "Test@gmail.com"}

	db.DB.Create(&organizer)

	organizer2 := models.User{Username: "organizer2Test", Password: PasswordHash, Role: "organizer", Email: "Test2@gmail.com"}

	db.DB.Create(&organizer2)

	admin := models.User{Username: "adminTest", Password: PasswordHash, Role: "admin", Email: "admin@gmail.com"}

	db.DB.Create(&admin)

	Organizer1 = organizer
	Organizer2 = organizer2
	Admin = admin
	User1 = user
	User2 = user2
}

func TestMain(m *testing.M) {
	router = initApp()

	user := models.User{Username: Admin.Username, Password: "password"}
	body, _ := json.Marshal(user)
	req, _ := http.NewRequest(http.MethodPost, "/api/v1/login", bytes.NewBuffer(body))

	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)
	// get value token from response
	var response map[string]string
	json.Unmarshal([]byte(resp.Body.String()), &response)
	TokenAdmin = response["token"]

	user2 := models.User{Username: User1.Username, Password: "password"}
	body2, _ := json.Marshal(user2)
	req2, _ := http.NewRequest(http.MethodPost, "/api/v1/login", bytes.NewBuffer(body2))

	resp2 := httptest.NewRecorder()
	router.ServeHTTP(resp2, req2)
	var response2 map[string]string
	json.Unmarshal([]byte(resp2.Body.String()), &response2)
	TokenUser1 = response2["token"]

	user3 := models.User{Username: "user2", Password: "password"}
	body3, _ := json.Marshal(user3)
	req3, _ := http.NewRequest(http.MethodPost, "/api/v1/login", bytes.NewBuffer(body3))

	resp3 := httptest.NewRecorder()
	router.ServeHTTP(resp3, req3)
	var response3 map[string]string
	json.Unmarshal([]byte(resp3.Body.String()), &response3)
	TokenUser2 = response3["token"]

	organizer := models.User{Username: Organizer1.Username, Password: "password"}
	body4, _ := json.Marshal(organizer)
	req4, _ := http.NewRequest(http.MethodPost, "/api/v1/login", bytes.NewBuffer(body4))

	resp4 := httptest.NewRecorder()
	router.ServeHTTP(resp4, req4)
	var response4 map[string]string
	json.Unmarshal([]byte(resp4.Body.String()), &response4)
	TokenOrganizer = response4["token"]

	organizer2 := models.User{Username: Organizer2.Username, Password: "password"}
	body5, _ := json.Marshal(organizer2)
	req5, _ := http.NewRequest(http.MethodPost, "/api/v1/login", bytes.NewBuffer(body5))

	resp5 := httptest.NewRecorder()
	router.ServeHTTP(resp5, req5)
	var response5 map[string]string
	json.Unmarshal([]byte(resp5.Body.String()), &response5)
	TokenOrganizer2 = response5["token"]

	os.Exit(m.Run())
}

func initApp() *gin.Engine {

	db.InitDB(true)
	//@TODO add default user if not exists with username: user, password: password
	var user models.User
	err := db.DB.AutoMigrate(&models.User{})
	if err != nil {
		return nil
	}
	db.DB.First(&user, "username = ?", "user")
	if user.ID == 0 {
		user = models.User{Username: "user", Password: PasswordHash, Email: "test@user.gmail.com"}
		db.DB.Create(&user)
	}

	CreateUserFixtures()
	CreateTournamentFixtures()

	router := routers.SetupRouter(db.DB)

	return router
}

func TestLoginWithValidCredentials(t *testing.T) {
	user := models.User{Username: "user", Password: "password"}
	body, _ := json.Marshal(user)
	req, _ := http.NewRequest(http.MethodPost, "/api/v1/login", bytes.NewBuffer(body))
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)
	assert.Contains(t, resp.Body.String(), "token")
}

func TestLoginWithInvalidCredentials(t *testing.T) {
	user := models.User{Username: "wrong", Password: "wrong"}
	body, _ := json.Marshal(user)
	req, _ := http.NewRequest(http.MethodPost, "/api/v1/login", bytes.NewBuffer(body))
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusUnauthorized, resp.Code)
	assert.Contains(t, resp.Body.String(), "Invalid credentials")
}

func TestRegisterWithValidData(t *testing.T) {
	rand.Seed(time.Now().UnixNano())

	randomNumber := rand.Intn(1000) // adjust the range as needed

	randomNumberStr := strconv.Itoa(randomNumber)

	user := models.User{
		Username: "test" + randomNumberStr,
		Password: "TEST1234!@#$",
		Email:    "test" + randomNumberStr + "@example.com",
	}

	body, _ := json.Marshal(user)
	req, _ := http.NewRequest(http.MethodPost, "/api/v1/register", bytes.NewBuffer(body))
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusCreated, resp.Code)
}

//func TestRegisterWithInvalidData(t *testing.T) {
//
//	body := bytes.NewBuffer([]byte(`{"invalid": "data"}`))
//	req, _ := http.NewRequest(http.MethodPost, "/api/v1/register", body)
//	resp := httptest.NewRecorder()
//
//	router.ServeHTTP(resp, req)
//
//	assert.Equal(t, http.StatusBadRequest, resp.Code)
//}

func TestSendSenderEmail(t *testing.T) {
	user := models.User{Username: "user", Password: "password", Email: "mats2@live.fr"}

	service := services.NewAuthService(db.DB)
	err := service.SendConfirmationEmail(user.Email, user.Username, user.VerificationToken)

	if err != nil {
		fmt.Print(err)
	}

	assert.Nil(t, err)

}
