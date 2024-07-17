package handlers

import (
	"authentication-api/errors"
	"authentication-api/models"
	"authentication-api/services"
	"authentication-api/utils"
	"fmt"
	"github.com/gin-gonic/gin"
	"io"
	"io/ioutil"
	"net/http"
	"os"
)

type AuthHandler struct {
	AuthService *services.AuthService
	UserService *services.UserService
}

func NewAuthHandler(authService *services.AuthService, userService *services.UserService) *AuthHandler {
	return &AuthHandler{
		AuthService: authService,
		UserService: userService,
	}
}

type RequestBody struct {
	Username string `json:"username"`
	Password string `json:"password"`
	FcmToken string `json:"fcm_token"`
}

type GoogleUser struct {
	UID         string `json:"uid"`
	Email       string `json:"email"`
	DisplayName string `json:"displayName"`
	PhotoURL    string `json:"photoURL"`
	FcmToken    string `json:"fcm_token"`
}

// Login godoc
// @Summary Login
// @Description Login
// @Tags Auth
// @Accept json
// @Produce json
// @Param payload body models.LoginPayload true "Login Payload"
// @Success 200 {object} string
// @Failure 400 {object} string
// @Failure 401 {object} string
// @Router /login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var user models.User
	var body RequestBody

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid data"})
		return
	}

	user.Username = body.Username
	user.Password = body.Password

	userData, err := h.AuthService.Login(&user)

	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	if !services.CheckPasswordHash(body.Password, userData.Password) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	if body.FcmToken != "" {
		err := h.UserService.AddFCMToken(userData.ID, body.FcmToken)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error adding FCM token"})
			return
		}
	}

	token, errToken := utils.GenerateToken(user)
	if errToken != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error generating token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})

}

// Register godoc
// @Summary Register
// @Description Register
// @Tags Auth
// @Accept json
// @Produce json
// @Param payload body models.NewUserPayload true "User Payload"
// @Success 201 {object} models.User
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Router /register [post]
func (h *AuthHandler) Register(c *gin.Context) {
	var user models.User

	user.VerificationToken = utils.GenerateRandomString(32)
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid data", err).ToGinH())
		return
	}

	hashedPassword, err := services.HashPassword(user.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error hashing password"})
		return
	}
	user.Password = hashedPassword

	errCreation := h.UserService.Create(&user)

	if err != nil {
		c.JSON(errCreation.Code(), err)
		return

	}

	errConfirm := h.AuthService.SendConfirmationEmail(user.Email, user.Username, user.VerificationToken)
	if errConfirm != nil {
		if validationErr, ok := err.(*errors.ValidationError); ok {
			c.JSON(http.StatusUnprocessableEntity, validationErr.ToGinH())
			return
		}

		c.JSON(errConfirm.Code(), err)
		return
	}

	c.JSON(http.StatusCreated, user.ToRead())
}

// ConfirmEmail godoc
// @Summary Confirm email
// @Description Confirm email
// @Tags Auth
// @Accept json
// @Produce json
// @Param token query string true "Token"
// @Success 200 {object} string
// @Failure 400 {object} string
// @Failure 401 {object} string
// @Router /confirm-email [get]
func (h *AuthHandler) ConfirmEmail(c *gin.Context) {
	token := c.Query("token")

	if token == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Token is required"})
		return
	}

	err := h.AuthService.VerifyEmail(token)

	if err != nil {
		c.JSON(err.Code(), err)
		return
	}

	c.JSON(http.StatusOK, "Email confirmed successfully")
}

func (h *AuthHandler) RegisterWithGoogle(c *gin.Context) {
	var googleUser GoogleUser
	fileService := services.NewFileService(h.UserService.Db)

	if err := c.ShouldBindJSON(&googleUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid data"})
		return
	}

	// Check if the user already exists in the database
	existingUser, err := h.UserService.FindByEmail(googleUser.Email)
	if err == nil && existingUser != nil {
		// User already exists, generate and return a token
		token, err := utils.GenerateToken(*existingUser)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create authentication token"})
			return
		}

		if googleUser.FcmToken != "" {
			err := h.UserService.AddFCMToken(existingUser.ID, googleUser.FcmToken)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Error adding FCM token"})
				return
			}
		}

		c.JSON(http.StatusOK, gin.H{
			"message": "User already exists, logged in successfully",
			"token":   token,
			"user":    existingUser.ToRead(),
		})
		return
	}

	// If user does not exist, create a new one
	user := models.User{
		Username: googleUser.DisplayName,
		Email:    googleUser.Email,
		Password: googleUser.UID,
		// Add other fields as necessary
	}

	if googleUser.PhotoURL != "" {
		response, err := http.Get(googleUser.PhotoURL)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to download the image"})
			return
		}
		defer response.Body.Close()

		contentType := response.Header.Get("Content-Type")
		fmt.Println("Content-Type:", contentType)

		if !IsImage(contentType) {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file type"})
			return
		}

		tmpFile, err := ioutil.TempFile(os.TempDir(), "prefix-")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create a temp file"})
			return
		}
		defer os.Remove(tmpFile.Name())
		fmt.Println("Temp file created:", tmpFile.Name())

		_, err = io.Copy(tmpFile, response.Body)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save the image to a temp file"})
			return
		}

		// Rewind the temporary file to the beginning
		_, err = tmpFile.Seek(0, 0)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to rewind the temp file"})
			return
		}

		// Check the file size and log it
		fileInfo, err := tmpFile.Stat()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get temp file info"})
			return
		}
		fmt.Println("Temp file size:", fileInfo.Size())

		mediaModel, _, errUpload := fileService.UploadMediaExt(tmpFile)
		if errUpload != nil {
			c.JSON(errUpload.Code(), gin.H{"error": errUpload.Error()})
			return
		}

		user.MediaModel.MediaID = &mediaModel.ID
	}

	errCreation := h.UserService.Create(&user)
	if errCreation != nil {
		c.JSON(errCreation.Code(), errCreation)
		return
	}

	// Generate token for the newly created user
	token, err := utils.GenerateToken(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create authentication token"})
		return
	}

	if googleUser.FcmToken != "" {
		err := h.UserService.AddFCMToken(user.ID, googleUser.FcmToken)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error adding FCM token"})
			return
		}
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "User created successfully",
		"token":   token,
		"user":    user.ToRead(),
	})
}
func IsImage(contentType string) bool {
	validImageTypes := map[string]bool{
		"image/jpeg": true,
		"image/png":  true,
		"image/gif":  true,
	}
	fmt.Println("Checking if valid image type:", contentType)
	return validImageTypes[contentType]
}
