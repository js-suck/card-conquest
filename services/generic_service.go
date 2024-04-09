package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	"fmt"
	"gorm.io/gorm"
)
import (
	"github.com/go-playground/validator/v10"
)

var validate *validator.Validate

func init() {
	validate = validator.New()
}

type Service interface {
	Create(m models.IModel) error
	Update(m models.IModel) error
	Delete(id uint) error
	Get(m models.IModel) (*models.IModel, error)
	GetAll(m interface{}) error
}

type GenericService struct {
	db    *gorm.DB
	model models.IModel
}

func NewGenericService(db *gorm.DB, model models.IModel) *GenericService {
	return &GenericService{db: db, model: model}
}

func (s *GenericService) Create(m models.IModel) error {
	if err := validate.Struct(m); err != nil {
		if _, ok := err.(*validator.InvalidValidationError); ok {
			return err
		}

		for _, err := range err.(validator.ValidationErrors) {
			errorMessage := fmt.Sprintf("Error in field: %s, Condition failed: %s", err.Field(), err.ActualTag())
			return errors.NewValidationError(errorMessage, err.Field())
		}
	}

	result := s.db.Create(m)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (s *GenericService) Update(m models.IModel) error {
	result := s.db.Save(m)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (s *GenericService) Delete(id uint) error {
	result := s.db.Delete(s.model, id)

	// if 0 rows affected, then the record does not exist
	if result.RowsAffected == 0 {
		return errors.NewNotFoundError("Record not found", nil)

	}

	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (s *GenericService) Get(model models.IModel, id uint) error {
	if err := s.db.First(&model, id).Error; err != nil {
		return err
	}

	return nil
}

//func (s *GenericService) UpdateById(id uint, updatedFields map[string]interface{}) error {
//	var entity IModel
//	if err := s.db.First(&entity, id).Error; err != nil {
//		return err
//	}
//
//	result := s.db.Model(&entity).Updates(updatedFields)
//	if result.Error != nil {
//		return result.Error
//	}
//
//	return nil
//}

func (s *GenericService) UpdateById(entity models.IModel, updatedFields map[string]interface{}) error {
	if err := s.db.First(entity, entity.GetID()).Error; err != nil {
		return err
	}

	result := s.db.Model(entity).Updates(updatedFields)
	if result.Error != nil {
		return result.Error
	}

	return nil
}

func (s *GenericService) GetAll(models interface{}) error {
	result := s.db.Find(models)
	if result.Error != nil {
		return result.Error
	}
	return nil
}
