package handlers

import (
	"authentication-api/services"
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
)

type UploadHandler struct {
	FileService *services.FileService
}

func NewUploadHandler(f *services.FileService) *UploadHandler {
	return &UploadHandler{FileService: f}
}

// UploadImage  godoc
// @Summary Upload an image
// @Description Upload an image
// @Tags Upload
// @Accept mpfd
// @Produce json
// @Param image formData file true "Image file"
// @Success 200 {object} string
// @Failure 400 {object} string
// @Router /images [post]
func (u *UploadHandler) UploadImage(c *gin.Context) {
	file, err := c.FormFile("image")

	mediaModel, filePath, errUpload := u.FileService.UploadMedia(file)
	if err != nil {
		c.JSON(errUpload.Code(), errUpload.Error())
		return
	}

	fmt.Println(filePath)
	c.JSON(http.StatusCreated, gin.H{"message": "Image uploaded successfully!", "media": mediaModel})
}
