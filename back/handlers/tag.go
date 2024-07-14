package handlers

import (
	"authentication-api/errors"
	"authentication-api/models"
	"authentication-api/services"
	"github.com/gin-gonic/gin"
	"net/http"
	"strconv"
)

type TagHandler struct {
	TagService *services.TagService
}

func NewTagHandler(tagService *services.TagService) *TagHandler {
	return &TagHandler{
		TagService: tagService,
	}
}

// GetAllTags godoc
// @Summary Get all tags
// @Description Get all tags.
// @Param WithTrendy query bool false "Add trendy games to the response"
// @Tags Tag
// @Accept json
// @Produce json
// @Success 200
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tags [get]
func (h *TagHandler) GetAllTags(c *gin.Context) {

	var tags []models.Tag
	filterParams := services.FilterParams{}

	err := h.TagService.GetAll(&tags, filterParams)

	if err != nil {
		c.JSON(err.Code(), err)
		return
	}

	c.JSON(http.StatusOK, tags)
}

// CreateTag godoc
// @Summary Create a tag
// @Description Create a tag
// @Tags Tag
// @Param tag body models.CreateTagPayload true "Tag object that needs to be created"
// @Accept json
// @Produce json
// @Success 200 {object} models.Tag
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tags [post]
func (h *TagHandler) CreateTag(c *gin.Context) {
	payload := models.CreateTagPayload{}

	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", err).ToGinH())
		return
	}

	tag := models.Tag{
		Label: payload.Label,
	}

	errorCreated := h.TagService.Create(&tag)
	if errorCreated != nil {
		c.JSON(errorCreated.Code(), errorCreated)
		return
	}

	c.JSON(http.StatusOK, "Tag created successfully")

}

// UpdateTag godoc
// @Summary Update a tag
// @Description Update a tag
// @Tags Tag
// @Param id path string true "Tag ID"
// @Param tag body models.Tag true "Tag object that needs to be updated"
// @Accept json
// @Produce json
// @Success 200 {object} models.Tag
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tags/{id} [put]
func (h *TagHandler) UpdateTag(context *gin.Context) {
	var tag models.Tag

	if err := context.ShouldBindJSON(&tag); err != nil {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", err).ToGinH())
		return
	}

	id := context.Param("id")
	if id == "" {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", nil).ToGinH())
		return
	}

	intID, err := strconv.Atoi(id)
	if err != nil {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID format", err).ToGinH())
		return
	}
	tag.ID = uint(intID)

	errUpdate := h.TagService.Update(&tag)
	if errUpdate != nil {
		context.JSON(errUpdate.Code(), err)
		return
	}

	context.JSON(http.StatusOK, "Tag updated successfully")
}

// DeleteTag godoc
// @Summary Delete a tag
// @Description Delete a tag
// @Tags Tag
// @Param id path string true "Tag ID"
// @Accept json
// @Produce json
// @Success 204
// @Failure 500 {object} errors.ErrorResponse
// @Security BearerAuth
// @Param Authorization header string true "Insert your access token" default(Bearer <Add access token here>)
// @Router /tags/{id} [delete]
func (h *TagHandler) DeleteTag(context *gin.Context) {
	id := context.Param("id")
	if id == "" {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid request", nil).ToGinH())
		return
	}

	intID, err := strconv.Atoi(id)
	if err != nil {
		context.JSON(http.StatusBadRequest, errors.NewBadRequestError("Invalid ID format", err).ToGinH())
		return
	}

	errDelete := h.TagService.Delete(uint(intID))
	if errDelete != nil {
		context.JSON(errDelete.Code(), errDelete)
		return
	}

	context.Status(http.StatusNoContent)
}
