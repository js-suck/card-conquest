package errors

import (
	"errors"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
	"net/http"
)

type ErrorResponse struct {
	ErrorMessage string `json:"message"`
	ErrorCode    int    `json:"code"`
}

type IError interface {
	error
	Code() int
}

func (e *ErrorResponse) Error() string {
	return e.ErrorMessage
}

type ValidationError struct {
	ErrorMessage string `json:"message"`
	ErrorCode    int    `json:"code"`
	Field        string `json:"field"`
}

func (e *ValidationError) Error() string {
	return e.ErrorMessage
}

func (e *ValidationError) ToGinH() gin.H {
	return gin.H{"error": e.ErrorMessage, "code": e.ErrorCode, "field": e.Field}
}

func (e *ValidationError) Code() int {
	return e.ErrorCode
}

func (e *ErrorResponse) Code() int {
	return e.ErrorCode
}

func (e *ErrorResponse) ToGinH() gin.H {
	return gin.H{"error": e.ErrorMessage, "code": e.ErrorCode}
}

func NewErrorResponse(code int, message string) *ErrorResponse {
	logrus.Error(message)
	return &ErrorResponse{
		ErrorMessage: message,
		ErrorCode:    code,
	}
}

func NewValidationError(message string, field string) *ValidationError {
	logrus.Error(message)
	return &ValidationError{
		ErrorMessage: message,
		ErrorCode:    http.StatusBadRequest,
		Field:        field,
	}
}

func NewBadRequestError(message string, err error) *ErrorResponse {
	fmt.Println(err)
	return NewErrorResponse(http.StatusBadRequest, message)
}

func NewNotFoundError(message string, err error) *ErrorResponse {
	fmt.Println(err)
	logrus.Error(message)
	return NewErrorResponse(http.StatusNotFound, message)
}

func NewInternalServerError(message string, err error) *ErrorResponse {
	logrus.Error(message)

	if customError, ok := err.(IError); ok {
		return NewErrorResponse(customError.Code(), customError.Error())

	}

	return NewErrorResponse(http.StatusInternalServerError, message)
}

func NewUnauthorizedError(message string) *ErrorResponse {
	logrus.Error(message)
	return NewErrorResponse(http.StatusUnauthorized, message)
}

func IsFileNotFound(err error) bool {

	return errors.Is(err, http.ErrMissingFile)
}
