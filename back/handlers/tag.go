package handlers

import (
	"authentication-api/errors"
	"authentication-api/models"
	"authentication-api/services"
	"github.com/gin-gonic/gin"
	"net/http"
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
