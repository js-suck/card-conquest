package test

import (
	"authentication-api/db"
	"authentication-api/models"
	"bytes"
	"fmt"
	"github.com/stretchr/testify/assert"
	"io"
	"math/rand"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"
)

func HttpWithAuthenticationTokenAndMultipart(method string, url string, body io.Reader, token string, contentType string) (*http.Request, error) {
	req, err := http.NewRequest(method, url, body)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", token)
	req.Header.Set("Content-Type", contentType)

	return req, nil
}

func HttpWithAuthenticationToken(method string, url string, body []byte, token string) (*http.Request, error) {
	req, err := http.NewRequest(method, url, bytes.NewBuffer(body))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", token)

	return req, nil
}

var TournamentOrganizer1 models.Tournament

func CreateTournamentFixtures() {

	db.DB.AutoMigrate(models.Tournament{}, models.Game{}, models.TournamentStep{})

	// Create a game
	game := models.Game{Name: "Game 1"}
	db.DB.Create(&game)

	// Create a tournament
	tournament := models.Tournament{
		Name:        fmt.Sprintf("Tournament %d", rand.Intn(100)),
		Description: "Description 1",
		GameID:      game.ID,
		Game:        game,
		StartDate:   "2021-01-01",
		EndDate:     "2021-01-02",
		Rounds:      3,
		MaxPlayers:  10,
		UserID:      Organizer1.ID,
	}

	db.DB.Create(&tournament)

	TournamentOrganizer1 = tournament
}

func TestCreateTournamentWithNoDescription(t *testing.T) {
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	writer.WriteField("name", "Tournament 1")
	writer.WriteField("game_id", "1")
	writer.WriteField("start_date", "2021-01-01")
	writer.WriteField("end_date", "2021-01-02")

	err := writer.Close()
	if err != nil {
		t.Fatal(err)
	}

	req, _ := HttpWithAuthenticationTokenAndMultipart(http.MethodPost, "/api/v1/tournaments", body, TokenAdmin, writer.FormDataContentType())
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusBadRequest, resp.Code)
	assert.Contains(t, resp.Body.String(), "Description, Condition failed: required")
}

func TestCreateTournamentWithNoName(t *testing.T) {
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	writer.WriteField("description", "Description 1")
	writer.WriteField("game_id", "1")
	writer.WriteField("start_date", "2021-01-01")
	writer.WriteField("end_date", "2021-01-02")

	err := writer.Close()
	if err != nil {
		t.Fatal(err)
	}

	req, _ := HttpWithAuthenticationTokenAndMultipart(http.MethodPost, "/api/v1/tournaments", body, TokenAdmin, writer.FormDataContentType())
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusBadRequest, resp.Code)
	assert.Contains(t, resp.Body.String(), "Error in field: Name, Condition failed: required")
}

func TestCreateValidTournament(t *testing.T) {
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	writer.WriteField("name", "Tournament 1")
	writer.WriteField("description", "Description 1")
	writer.WriteField("game_id", "1")
	writer.WriteField("start_date", "2021-01-01")
	writer.WriteField("end_date", "2021-01-02")
	writer.WriteField("rounds", "3")
	writer.WriteField("max_players", "10")
	writer.WriteField("organizer_id", "1")

	err := writer.Close()
	if err != nil {
		t.Fatal(err)
	}

	req, _ := HttpWithAuthenticationTokenAndMultipart(http.MethodPost, "/api/v1/tournaments", body, TokenAdmin, writer.FormDataContentType())
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)
}

// if the user is not an organizer, the request should be forbidden
func TestCreateTournamentWithInvalidPermissions(t *testing.T) {
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	writer.WriteField("name", "Tournament 1")
	writer.WriteField("description", "Description 1")
	writer.WriteField("game_id", "1")
	writer.WriteField("start_date", "2021-01-01")
	writer.WriteField("end_date", "2021-01-02")
	writer.WriteField("rounds", "3")
	writer.WriteField("max_players", "10")
	writer.WriteField("organizer_id", strconv.Itoa(int(User1.ID)))

	err := writer.Close()
	if err != nil {
		t.Fatal(err)
	}

	req, _ := HttpWithAuthenticationTokenAndMultipart(http.MethodPost, "/api/v1/tournaments", body, TokenUser1, writer.FormDataContentType())
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusForbidden, resp.Code)
}

func TestCreateTournamentAsAnOrganize(t *testing.T) {
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	writer.WriteField("name", "Tournament 3")
	writer.WriteField("description", "Description 2")
	writer.WriteField("game_id", "1")
	writer.WriteField("start_date", "2021-01-01")
	writer.WriteField("end_date", "2021-01-02")
	writer.WriteField("rounds", "3")
	writer.WriteField("max_players", "10")
	writer.WriteField("organizer_id", strconv.Itoa(int(Organizer1.ID)))

	err := writer.Close()
	if err != nil {
		t.Fatal(err)
	}

	req, _ := HttpWithAuthenticationTokenAndMultipart(http.MethodPost, "/api/v1/tournaments", body, TokenOrganizer, writer.FormDataContentType())
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)
}

func TestUpdateTournamentValid(t *testing.T) {

	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	writer.WriteField("name", fmt.Sprintf("Tournament %d", rand.Intn(100)))

	err := writer.Close()
	if err != nil {
		t.Fatal(err)
	}

	req, _ := HttpWithAuthenticationTokenAndMultipart(http.MethodPut, "/api/v1/tournaments/1", body, TokenAdmin, writer.FormDataContentType())
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)
	assert.Contains(t, resp.Body.String(), "Tournament updated successfully")
}

func TestUpdateTournamentFromOtherOrganizer(t *testing.T) {

	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	writer.WriteField("name", fmt.Sprintf("Tournament %d", rand.Intn(100)))

	err := writer.Close()
	if err != nil {
		t.Fatal(err)
	}

	req, _ := HttpWithAuthenticationTokenAndMultipart(http.MethodPut, "/api/v1/tournaments/1", body, TokenOrganizer, writer.FormDataContentType())
	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusForbidden, resp.Code)
	assert.Contains(t, resp.Body.String(), "forbidden")
}

func TestUpdateMyTournament(t *testing.T) {

	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	writer.WriteField("name", fmt.Sprintf("Tournament %d", rand.Intn(100)))

	err := writer.Close()

	if err != nil {
		t.Fatal(err)
	}

	req, _ := HttpWithAuthenticationTokenAndMultipart(http.MethodPut, fmt.Sprintf("/api/v1/tournaments/%d", TournamentOrganizer1.ID), body, TokenOrganizer, writer.FormDataContentType())

	resp := httptest.NewRecorder()

	router.ServeHTTP(resp, req)

	assert.Equal(t, http.StatusOK, resp.Code)

}
