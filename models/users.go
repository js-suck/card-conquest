package models

import (
	"time"
)

type IModel interface {
	GetID() uint
	GetTableName() string
}

type BaseModel struct {
	ID        uint       `gorm:"primarykey" json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `gorm:"index" json:"-"`
}

type User struct {
	BaseModel
	Username string `gorm:"unique;not null;type:varchar(100);default:null" json:"username" validate:"required"`
	Password string `gorm:"unique;not null;type:varchar(100);default:null" json:"password" validate:"required"`
	Address  string `gorm:"type:varchar(255);default:null" json:"address"`
	Phone    string `gorm:"type:varchar(30);default:null" json:"phone"`
	Email    string `gorm:"type:varchar(255);default:null" json:"email"`
	Role     string `gorm:"type:varchar(100);default:user" json:"role"`
	Country  string `gorm:"type:varchar(255);default:null" json:"country"`
}

type LoginPayload struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type NewUserPayload struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func (u User) GetTableName() string {
	return "users"
}

type NewUserToken struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func (u User) GetID() uint {
	return u.ID
}
