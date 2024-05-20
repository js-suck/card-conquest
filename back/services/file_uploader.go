package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	"gorm.io/gorm"
	"io/ioutil"
	"mime/multipart"
	"os"
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

	filePath := "./back/uploads/" + file.Filename
	err = ioutil.WriteFile(filePath, fileBytes, os.ModePerm)
	if err != nil {
		return nil, "", errors.NewBadRequestError("something went wrong with file", err)
	}

	media := models.Media{
		FileName:      file.Filename,
		FileExtension: file.Header.Get("Content-Type"),
	}

	mediaModel, errModel := persistMedia(f.db, media)

	if errModel != nil {
		return nil, "", errors.NewInternalServerError("something went wrong with file", err)
	}

	return mediaModel, filePath, nil
}
