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
	FileService *services.FileService
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
// @Router /users/{id} [get]
func (h *UserHandler) GetUser() gin.HandlerFunc {
	return func(c *gin.Context) {
		idStr := c.Param("id")
		idInt, err := strconv.Atoi(idStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
			return
		}

		user := models.User{}

		err = h.UserService.Get(&user, uint(idInt), "Media")
		if err != nil {
			c.JSON(http.StatusNotFound, errors.NewNotFoundError("User not found", err).ToGinH())
			return
		}

		c.JSON(http.StatusOK, user.ToReadFull())
	}
}

func parseFilterParams(c *gin.Context) services.FilterParams {
	isActive := c.Query("isVerified")
	role := c.Query("role")
	country := c.Query("country")
	sort := c.Query("sort")

	filterParams := services.FilterParams{
		Fields: map[string]interface{}{},
		Sort:   []string{},
	}

	if isActive != "" {
		isActiveBool, err := strconv.ParseBool(isActive)
		if err == nil {
			filterParams.Fields["is_verified"] = isActiveBool
		}
	}

	if role != "" {
		filterParams.Fields["role"] = role
	}

	if country != "" {
		filterParams.Fields["country"] = country

	}

	if sort != "" {
		filterParams.Sort = append(filterParams.Sort, sort)
	}

	return filterParams
}

// GetUsers godoc
// @basePath: /api/v1
// @Summary Get all users
// @Description Get all users
// @Param isVerified query string false "Filter by isVerified"
// @Param sort query string false "Sort by"
// @Param role query string false "Filter by role"
// @Param country query string false "Filter by country"
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
	filterParams := parseFilterParams(c)
	err := h.UserService.GetAll(&users, filterParams, "Media")

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
	userIDStr := c.Param("id")
	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	user := models.User{}
	err = h.UserService.Get(&user, uint(userID), "Media")
	if err != nil {
		c.JSON(http.StatusNotFound, errors.NewNotFoundError("User not found", err).ToGinH())
		return
	}

	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid data", err).ToGinH())
		return
	}

	err = h.UserService.Update(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, errors.NewInternalServerError("Error updating user", err).ToGinH())
		return
	}

	c.JSON(http.StatusOK, "User updated successfully")
}

// UploadPicture godoc
// @basePath: /api/v1
// @Summary Upload a picture
// @Description Upload a picture
// @Tags User
// @Accept mpfd
// @Produce json
// @Param id path int true "User ID"
// @Param image formData file true "Image file"
// @Success 200 {object} string
// @Failure 400 {object} errors.ErrorResponse
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /users/{id}/upload/picture [post]
func (h *UserHandler) UploadPicture(c *gin.Context) {
	// create media
	file, err := c.FormFile("image")

	mediaModel, filePath, errUpload := h.FileService.UploadMedia(file)
	if err != nil {
		c.JSON(errUpload.Code(), errUpload.Error())
		return
	}
	idStr := c.Param("id")

	idInt, err := strconv.Atoi(idStr)

	if err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return

	}

	user := models.User{}

	err = h.UserService.Get(&user, uint(idInt), "Media")
	if err != nil {
		c.JSON(http.StatusNotFound, errors.NewNotFoundError("User not found", err).ToGinH())
		return
	}
	user.MediaModel.MediaID = &mediaModel.ID
	err = h.UserService.Update(user)
	c.JSON(http.StatusOK, gin.H{"message": "Image uploaded successfully!", "path": filePath})

}

// GetUsersRanks godoc
// @basePath: /api/v1
// @Summary Get users ranks
// @Description Get users ranks
// @Tags User
// @Accept json
// @Produce json
// @Success 200 {object} []models.UserRanking
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /users/ranks [get]
func (h *UserHandler) GetUsersRanks(context *gin.Context) {
	userRankings, err := h.UserService.GetRanks()
	if err != nil {
		context.JSON(err.Code(), err)
		return
	}

	context.JSON(http.StatusOK, userRankings)
}

// GetUserStats godoc
// @basePath: /api/v1
// @Summary Get user stats
// @Description Get user stats
// @Tags User
// @Accept json
// @Produce json
// @Success 200 {object} models.UserStats
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param UserID path int true "User ID"
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /users/{UserID}/stats [get]
func (h *UserHandler) GetUserStats(context *gin.Context) {
	userId := context.Param("id")

	userInt, err := strconv.Atoi(userId)
	if err != nil {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID", err).ToGinH())
		return
	}

	userStats, err := h.UserService.GetUserStats(uint(userInt))
	if err != nil {
		context.JSON(http.StatusInternalServerError, errors.NewInternalServerError("Failed to get user stats", err).ToGinH())
		return
	}

	context.JSON(http.StatusOK, userStats)
}
