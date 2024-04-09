package handlers

import (
	"authentication-api/models"
	"authentication-api/services"
	"authentication-api/utils"
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
)

type AuthHandler struct {
	AuthService *services.AuthService
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

	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid data"})
		return
	}

	err := h.AuthService.Login(&user)

	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid credentials"})
		return
	}

	token, err := utils.GenerateToken(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error generating token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})

}

func Register(c *gin.Context) {
	var user models.User

	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid data"})
		fmt.Println(err)
		return
	}

	user.ID = 1
	c.JSON(http.StatusCreated, gin.H{"message": "User registered successfully"})
}
