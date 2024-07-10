package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	"fmt"
	"gorm.io/gorm"
	"io/ioutil"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strings"
)

type FileService struct {
	// This service can use all the methods of genericService or can override it
	*GenericService
}

func NewFileService(db *gorm.DB) *FileService {
	return &FileService{
		GenericService: NewGenericService(db, models.Media{}),
	}
}

func persistMedia(db *gorm.DB, media models.Media) (*models.Media, errors.IError) {
	result := db.Create(&media)
	if result.Error != nil {
		return nil, errors.NewErrorResponse(500, result.Error.Error())
	}
	return &media, nil
}

func (f *FileService) UploadMedia(file *multipart.FileHeader) (*models.Media, string, errors.IError) {
	src, err := file.Open()
	if err != nil {
		return nil, "", errors.NewBadRequestError("something went wrong with file", err)
	}
	defer src.Close()

	fileBytes, err := ioutil.ReadAll(src)
	if err != nil {
		return nil, "", errors.NewBadRequestError("something went wrong with file", err)
	}

	filePath := "./uploads/" + file.Filename
	err = ioutil.WriteFile(filePath, fileBytes, os.ModePerm)
	if err != nil {
		return nil, "", errors.NewBadRequestError("something went wrong with file", err)
	}

	media := models.Media{
		FileName:      file.Filename,
		FileExtension: file.Header.Get("Content-Type"),
	}

	mediaModel, errModel := persistMedia(f.Db, media)

	if errModel != nil {
		return nil, "", errors.NewInternalServerError("something went wrong with file", err)
	}

	return mediaModel, filePath, nil
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

func (f *FileService) UploadMediaExt(file *os.File) (*models.Media, string, errors.IError) {
	// Read the file to a buffer to determine its type
	fileBytes, err := ioutil.ReadAll(file)
	if err != nil {
		fmt.Println("Error reading file:", err)
		return nil, "", errors.NewBadRequestError("something went wrong with file", err)
	}

	// Validate the MIME type of the file
	fileType := http.DetectContentType(fileBytes)
	if !IsImage(fileType) {
		fmt.Println("Invalid file type detected:", fileType)
		return nil, "", errors.NewBadRequestError("Invalid file type detected", nil)
	}

	// Determine the correct file extension based on MIME type
	fileExt := getFileExtension(fileType)
	if fileExt == "" {
		fmt.Println("Could not determine file extension for type:", fileType)
		return nil, "", errors.NewBadRequestError("Could not determine file extension", nil)
	}

	dir := "./uploads/"
	err = os.MkdirAll(dir, os.ModePerm)
	if err != nil {
		fmt.Println("Error creating directory:", err)
		return nil, "", errors.NewInternalServerError("Failed to create uploads directory", err)
	}

	fileName := filepath.Base(file.Name()) + fileExt
	filePath := filepath.Join(dir, fileName)
	fmt.Println("File path for saving:", filePath)
	err = ioutil.WriteFile(filePath, fileBytes, os.ModePerm)
	if err != nil {
		fmt.Println("Error writing file:", err)
		return nil, "", errors.NewBadRequestError("Failed to save the file", err)
	}

	media := models.Media{
		FileName:      fileName,
		FileExtension: strings.TrimPrefix(fileExt, "."),
	}

	mediaModel, errModel := persistMedia(f.Db, media)
	if errModel != nil {
		fmt.Println("Error persisting media:", errModel)
		return nil, "", errors.NewInternalServerError("Failed to persist media", errModel)
	}

	return mediaModel, filePath, nil
}

func getFileExtension(mimeType string) string {
	switch mimeType {
	case "image/jpeg":
		return ".jpg"
	case "image/png":
		return ".png"
	case "image/gif":
		return ".gif"
	default:
		return ""
	}
}
