package utils

import (
	"authentication-api/models"
	"fmt"
	"github.com/golang-jwt/jwt/v5"
	"time"
)

var secretKey = []byte("vivianméchant")

func GenerateToken(user models.User) (string, error) {
	claims := jwt.MapClaims{}
	claims["user_id"] = user.ID
	claims["name"] = user.Username
	claims["role"] = user.Role
	claims["exp"] = time.Now().Add(time.Hour * 6).Unix() // Token is valid for 6 hours (to decrease later when on first prod) :)

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(secretKey)
}
func VerifyToken(tokenString string) (jwt.MapClaims, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("Invalid signing method")
		}

		return secretKey, nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims, nil
	}

	return nil, fmt.Errorf("Invalid token")
}
