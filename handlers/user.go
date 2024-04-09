package handlers

import (
	"authentication-api/errors"
	"authentication-api/models"
	"authentication-api/permissions"
	"authentication-api/services"
	"github.com/gin-gonic/gin"
	"net/http"
	"strconv"
)

type UserHandler struct {
	UserService *services.UserService
}

// GetUser godoc
// @basePath: /api/v1
// @Summary Get a user by ID
// @Description Get a user by ID
// @Tags User
// @Accept json
// @Produce json
// @Param id path int true "User ID"
// @Success 200 {object} models.User
// @Failure 400 {object} errors.ErrorResponse
// @Failure 404 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /user/{id} [get]
func (h *UserHandler) GetUser() gin.HandlerFunc {
	return func(c *gin.Context) {
		idStr := c.Param("id")
		idInt, err := strconv.Atoi(idStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
			return
		}

		user := models.User{}

		err = h.UserService.Get(&user, uint(idInt))
		if err != nil {
			c.JSON(http.StatusNotFound, errors.NewNotFoundError("User not found", err).ToGinH())
			return
		}

		c.JSON(http.StatusOK, user)
	}
}

// GetUsers godoc
// @basePath: /api/v1
// @Summary Get all users
// @Description Get all users
// @Tags User
// @Accept json
// @Produce json
// @Success 200 {object} string
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /users [get]
func (h *UserHandler) GetUsers(c *gin.Context) {

	var users []models.User
	err := h.UserService.GetAll(&users)

	if err != nil {
		c.JSON(http.StatusInternalServerError, errors.NewInternalServerError("Error getting users", err).ToGinH())
		return
	}

	c.JSON(http.StatusOK, users)
}

// PostUser godoc
// @basePath: /api/v1
// @Summary Create a user
// @Description Create a user
// @Tags User
// @Accept json
// @Produce json
// @Param payload body models.User true "User Payload"
// @Success 201 {object} models.NewUserPayload
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /users [post]
func (h *UserHandler) PostUser(c *gin.Context) {
	var user models.User

	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid data", err).ToGinH())
		return
	}

	err := h.UserService.Create(&user)
	if err != nil {
		if validationErr, ok := err.(*errors.ValidationError); ok {
			c.JSON(http.StatusUnprocessableEntity, validationErr.ToGinH())
			return
		}

		c.JSON(http.StatusInternalServerError, errors.NewInternalServerError("Error creating user", err).ToGinH())
		return
	}

	c.JSON(http.StatusCreated, user)
}

// DeleteUser godoc
// @basePath: /api/v1
// @Summary Delete a user
// @Description Delete a user
// @Tags User
// @Accept json
// @Produce json
// @Param id path int true "User ID"
// @Success 204
// @Failure 400 {object} errors.ErrorResponse
// @Failure 404 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /users/{id} [delete]
func (h *UserHandler) DeleteUser(c *gin.Context) {

	permissionsConfigs := c.MustGet("permissions").([]permissions.Permission)

	canAccess := permissions.CanAccess(permissionsConfigs, permissions.PermissionDeleteUser)

	if !canAccess {
		c.JSON(http.StatusForbidden, errors.NewUnauthorizedError("You do not have permission to access this resource").ToGinH())
		return
	}

	idStr := c.Param("id")
	idInt, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	err = h.UserService.Delete(uint(idInt))
	if err != nil {
		c.JSON(http.StatusNotFound, err)
		return
	}

	c.Status(http.StatusNoContent)
}

// UpdateUser godoc
// @basePath: /api/v1
// @Summary Update a user
// @Description Update a user
// @Tags User
// @Accept json
// @Produce json
// @Param payload body models.User true "User Payload"
// @Success 200 {object} models.User
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /users/{id} [put]
func (h *UserHandler) UpdateUser(c *gin.Context) {
	permissionsConfigs := c.MustGet("permissions").([]permissions.Permission)

	canAccess := permissions.CanAccess(permissionsConfigs, permissions.PermissionCreateUser)

	if !canAccess {
		c.JSON(http.StatusForbidden, errors.NewUnauthorizedError("You do not have permission to access this resource").ToGinH())
		return
	}

	var user models.User

	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid data", err).ToGinH())
		return
	}

	err := h.UserService.Update(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, errors.NewInternalServerError("Error updating user", err).ToGinH())
		return
	}

	c.JSON(http.StatusOK, user)
}
