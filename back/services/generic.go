package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	"fmt"
	"github.com/go-playground/validator/v10"
	"gorm.io/gorm"
	"strings"
)

var validate *validator.Validate

func init() {
	validate = validator.New()
}

type Service interface {
	Create(m models.IModel) errors.IError
	Update(m models.IModel) error
	Delete(id uint) error
	Get(model models.IModel, id uint, preloads ...string) errors.IError
	GetAll(models interface{}, filterParams FilterParams, preloads ...string) errors.IError
}

type GenericService struct {
	Db    *gorm.DB
	model models.IModel
}

func NewGenericService(db *gorm.DB, model models.IModel) *GenericService {
	return &GenericService{Db: db, model: model}
}

type FilterParams struct {
	Fields map[string]interface{} // Conditions de filtrage => clé: champ, valeur: valeur attendue
	Sort   []string               // Champs pour le tri =>  préfixés par "-" pour un tri descendant (ex Sort=-username)
}

func (s *GenericService) Create(m models.IModel) errors.IError {

	if err := validate.Struct(m); err != nil {
		if _, ok := err.(*validator.InvalidValidationError); ok {
			return errors.NewValidationError("Invalid validation error", "")
		}

		for _, err := range err.(validator.ValidationErrors) {
			errorMessage := fmt.Sprintf("Error in field: %s, Condition failed: %s", err.Field(), err.ActualTag())
			return errors.NewValidationError(errorMessage, err.Field())
		}

	}

	result := s.Db.Create(m)
	if result.Error != nil {
		return errors.NewErrorResponse(400, result.Error.Error())
	}
	return nil
}

func (s *GenericService) Update(m models.IModel) errors.IError {
	result := s.Db.Model(m).Updates(m)
	if result.Error != nil {
		return errors.NewErrorResponse(500, result.Error.Error())
	}
	return nil
}

func (s *GenericService) Delete(id uint) errors.IError {
	result := s.Db.Delete(s.model, id)

	if result.RowsAffected == 0 {
		return errors.NewNotFoundError("Record not found", nil)

	}

	if result.Error != nil {
		return errors.NewErrorResponse(500, result.Error.Error())
	}
	return nil
}

func (s *GenericService) Get(model models.IModel, id uint, preloads ...string) errors.IError {
	db := s.Db
	for _, preload := range preloads {
		db = db.Preload(preload)
	}

	if err := db.First(model, id).Error; err != nil {
		return errors.NewErrorResponse(500, err.Error())
	}

	return nil
}

func (s *GenericService) GetAll(models interface{}, filterParams FilterParams, preloads ...string) errors.IError {
	query := s.Db

	for field, value := range filterParams.Fields {
		query = query.Where(field+" = ?", value)
	}

	for _, preload := range preloads {
		query = query.Preload(preload)
	}

	for _, sortField := range filterParams.Sort {
		if strings.HasPrefix(sortField, "-") {
			query = query.Order(sortField[1:] + " desc")
		} else {
			query = query.Order(sortField)
		}
	}

	result := query.Find(models)
	if result.Error != nil {
		return errors.NewErrorResponse(500, result.Error.Error())
	}

	return nil
}
