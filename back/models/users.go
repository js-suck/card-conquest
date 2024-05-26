package models

import (
	"time"
)

type IModel interface {
	GetID() uint
	GetTableName() string
}

type ForeignKeyChecker interface {
	GetForeignKeyValue() (value interface{}, model IModel)
}

type BaseModel struct {
	ID        uint       `gorm:"primarykey" json:"id"`
	CreatedAt time.Time  `json:"created_at, omitempty"`
	UpdatedAt time.Time  `json:"updated_at, omitempty"`
	DeletedAt *time.Time `gorm:"index" json:"-"`
}

type MediaModel struct {
	MediaID *uint  `json:"media_id"`
	Media   *Media `json:"media" gorm:"foreignKey:MediaID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
}

type User struct {
	BaseModel
	MediaModel
	Username          string        `gorm:"unique;not null;type:varchar(100);default:null" json:"username"`
	Password          string        `gorm:"not null;type:varchar(100);default:null" json:"password" validate:"required,min=6"`
	Address           string        `gorm:"type:varchar(255);default:null" json:"address"`
	Phone             string        `gorm:"type:varchar(30);default:null" json:"phone"`
	Email             string        `gorm:"unique;not null;type:varchar(255);default:null" json:"email"`
	Role              string        `gorm:"type:varchar(100);default:user" json:"role"`
	Country           string        `gorm:"type:varchar(255);default:null" json:"country"`
	VerificationToken string        `gorm:"type:varchar(255);default:null" json:"-"`
	IsVerified        bool          `gorm:"default:false" json:"is_verified"`
	Tournaments       []*Tournament `gorm:"many2many:user_tournaments;"`
	Matches           []Match       `gorm:"foreignKey:PlayerOneID;references:ID"`
}

type LoginPayload struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type NewUserPayload struct {
	Username string `json:"username" example:"username"`
	Password string `json:"password" example:"password"`
	Address  string `json:"address" example:"1234 street"`
	Phone    string `json:"phone" example:"1234567890"`
	Email    string `json:"email" example:"test@example.com`
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

func (u User) ToRead() interface{} {
	return UserReadTournament{
		ID:    u.ID,
		Name:  u.Username,
		Email: u.Email,
	}
}
