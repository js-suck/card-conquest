package errors

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
)

type ErrorResponse struct {
	Message string `json:"message"`
	Code    int    `json:"code"`
}

func (e *ErrorResponse) Error() string {
	//TODO implement me
	panic("implement me")
}

type ValidationError struct {
	Message string `json:"message"`
	Code    int    `json:"code"`
	Field   string `json:"field"`
}

func (e *ValidationError) Error() string {
	//TODO implement me
	panic("implement me")
}

func (e *ValidationError) ToGinH() gin.H {
	return gin.H{"error": e.Message, "code": e.Code, "field": e.Field}
}

func (e *ErrorResponse) ToGinH() gin.H {
	return gin.H{"error": e.Message, "code": e.Code}
}

func NewErrorResponse(code int, message string) *ErrorResponse {
	return &ErrorResponse{
		Message: message,
		Code:    code,
	}
}

func NewValidationError(message string, field string) *ValidationError {
	return &ValidationError{
		Message: message,
		Code:    http.StatusUnprocessableEntity,
		Field:   field,
	}
}

func NewBadRequestError(message string, err error) *ErrorResponse {
	fmt.Println(err)
	return NewErrorResponse(http.StatusBadRequest, message)
}

func NewNotFoundError(message string, err error) *ErrorResponse {
	fmt.Println(err)
	return NewErrorResponse(http.StatusNotFound, message)
}

func NewInternalServerError(message string, err error) *ErrorResponse {
	return NewErrorResponse(http.StatusInternalServerError, message)
}

func NewUnauthorizedError(message string) *ErrorResponse {
	return NewErrorResponse(http.StatusUnauthorized, message)
}
