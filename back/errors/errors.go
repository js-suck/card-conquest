package errors

import (
	"fmt"
	"github.com/gin-gonic/gin"
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
	//TODO implement me
	panic("implement me")
}

type ValidationError struct {
	ErrorMessage string `json:"message"`
	ErrorCode    int    `json:"code"`
	Field        string `json:"field"`
}

func (e *ValidationError) Error() string {
	//TODO implement me
	panic("implement me")
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
	return &ErrorResponse{
		ErrorMessage: message,
		ErrorCode:    code,
	}
}

func NewValidationError(message string, field string) *ValidationError {
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
	return NewErrorResponse(http.StatusNotFound, message)
}

func NewInternalServerError(message string, err error) *ErrorResponse {
	return NewErrorResponse(http.StatusInternalServerError, message)
}

func NewUnauthorizedError(message string) *ErrorResponse {
	return NewErrorResponse(http.StatusUnauthorized, message)
}
