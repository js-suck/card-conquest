package services

import (
	"authentication-api/errors"
	"authentication-api/models"
	"fmt"
	"github.com/mailjet/mailjet-apiv3-go"

	"gorm.io/gorm"
	"log"
)

type AuthService struct {
	db *gorm.DB
}

func NewAuthService(db *gorm.DB) *AuthService {
	return &AuthService{db: db}
}

func (a AuthService) Login(user *models.User) error {
	a.db.Where("username = ? AND password = ?", user.Username, user.Password).First(&user)
	if user.ID == 0 {
		return errors.NewBadRequestError("invalid credentials", nil)
	}

	return nil
}

func (a AuthService) SendConfirmationEmail(to, name, token string) errors.IError {
	mailjetClient := mailjet.NewMailjetClient("dfaaa1f406a6a163ed3cfd1c77387ae4", "0d63be9d2ffb6ef31625967ee81f5a56")

	messagesInfo := []mailjet.InfoMessagesV31{
		mailjet.InfoMessagesV31{
			From: &mailjet.RecipientV31{
				Email: "laila.charaoui@outlook.fr",
				Name:  "Registration valid",
			},
			To: &mailjet.RecipientsV31{
				mailjet.RecipientV31{
					Email: to,
					Name:  name,
				},
			},
			TemplateID:       4612337,
			TemplateLanguage: true,
			Subject:          "Welcome to CardConquest",
			Variables: map[string]interface{}{
				"confirmation_link": fmt.Sprintf("http://localhost:8080/api/v1/users/verify?token=%s", token),
			},
		},
	}
	messages := mailjet.MessagesV31{Info: messagesInfo}
	res, err := mailjetClient.SendMailV31(&messages)
	if err != nil {
		log.Fatal(err)
		return errors.NewErrorResponse(500, err.Error())
	}

	fmt.Printf("Data: %+v", res)

	return nil
}

func (a AuthService) VerifyEmail(token string) errors.IError {
	var user models.User
	a.db.Where("verification_token = ?", token).First(&user)
	if user.ID == 0 {
		return errors.NewBadRequestError("invalid token", nil)
	}

	user.IsVerified = true
	result := a.db.Save(&user)
	if result.Error != nil {
		return errors.NewErrorResponse(500, result.Error.Error())
	}

	return nil
}

func (a AuthService) Register(user *models.User) errors.IError {

	result := a.db.Create(&user)
	if result.Error != nil {
		return errors.NewErrorResponse(400, result.Error.Error())
	}
	return nil
}
