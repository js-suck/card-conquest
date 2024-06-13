package handlers

import (
	"authentication-api/errors"
	"authentication-api/models"
	"authentication-api/services"
	"authentication-api/utils"
	"github.com/gin-gonic/gin"
	"net/http"
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

	err := h.UserService.Create(&user)

	if err != nil {
		c.JSON(err.Code(), err)
		return

	}

	err = h.AuthService.SendConfirmationEmail(user.Email, user.Username, user.VerificationToken)
	if err != nil {
		if validationErr, ok := err.(*errors.ValidationError); ok {
			c.JSON(http.StatusUnprocessableEntity, validationErr.ToGinH())
			return
		}

		c.JSON(err.Code(), err)
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
