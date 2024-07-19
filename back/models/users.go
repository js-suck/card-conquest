package models

import (
	"gorm.io/gorm"
	"time"
)

type IModel interface {
	GetID() uint
	GetTableName() string
	IsOwner(userID uint) bool
	New() IModel
}

type ForeignKeyChecker interface {
	GetForeignKeyValue() (value interface{}, model IModel)
}

type BaseModel struct {
	ID        uint       `gorm:"primary_key;auto_increment" json:"id"`
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
	Username             string        `gorm:"unique;not null;type:varchar(100);default:null" json:"username"`
	Password             string        `gorm:"not null;type:varchar(100);default:null" json:"password" validate:"required,min=6"`
	Address              string        `gorm:"type:varchar(255);default:null" json:"address"`
	Phone                string        `gorm:"type:varchar(30);default:null" json:"phone"`
	Email                string        `gorm:"unique;not null;type:varchar(255);default:null" json:"email"`
	Role                 string        `gorm:"type:varchar(100);default:user" json:"role"`
	Country              string        `gorm:"type:varchar(255);default:null" json:"country"`
	GlobalScore          int           `gorm:"default:0" json:"global_score"`
	VerificationToken    string        `gorm:"type:varchar(255);default:null" json:"-"`
	IsVerified           bool          `gorm:"default:false" json:"is_verified"`
	Tournaments          []*Tournament `gorm:"many2many:user_tournaments;constraint:OnDelete:CASCADE;"`
	Matches              []Match       `gorm:"foreignKey:PlayerOneID;references:ID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
	GamesScores          []GameScore   `gorm:"foreignKey:UserID;references:ID"`
	Guilds               []Guild       `gorm:"many2many:guild_players;constraint:OnDelete:CASCADE;"`
	FCMToken             string        `gorm:"type:varchar(255);default:null" json:"fcm_token"; default:null`
	SuscribedTournaments []Tournament  `gorm:"many2many:user_suscribed_tournaments;constraint:OnDelete:CASCADE;"`
}

func (u *User) New() IModel {
	return &User{}
}

type NewUserGoogle struct {
	Username string `json:"username"`
	Email    string `json:"email"`
}

func (u *User) AfterFind(tx *gorm.DB) (err error) {
	tx.Model(u).Association("Media").Find(&u.Media)
	return
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

type UserRead struct {
	ID       uint   `gorm:"primarykey"`
	Username string `json:"name"`
	Email    string `json:"email, -"`
}

type UserReadWithImage struct {
	ID       uint
	Username string `json:"username"`
	Email    string `json:"email"`
	Media    *Media `json:"media"`
	Score    int    `json:"score"`
}

type UserReadFull struct {
	ID         uint        `json:"id"`
	Username   string      `json:"username"`
	Email      string      `json:"email"`
	Address    string      `json:"address"`
	Phone      string      `json:"phone"`
	Role       string      `json:"role"`
	Country    string      `json:"country"`
	MediaModel *Media      `json:"media"`
	Guilds     []GuildRead `json:"guilds"`
}

type UserRanking struct {
	User  UserReadTournament
	Score int
	Rank  int
}

type UserStats struct {
	*UserReadTournament
	TotalMatches int
	TotalWins    int
	TotalLosses  int
	TotalScore   int
	Rank         int
	GamesRanking []UserGameRanking
}

type UserGameRanking struct {
	User     UserReadTournament
	GameID   uint
	GameName string
	Score    int
	Rank     int
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

func (u User) ToRead() UserReadTournament {
	user := UserReadTournament{
		ID:    u.ID,
		Name:  u.Username,
		Email: u.Email,
	}

	if u.MediaModel.Media != nil && u.MediaModel.Media.FileName != "" {
		user.Media = u.MediaModel.Media
	}

	return user
}

func (u User) ToReadFull() UserReadFull {
	userRead := UserReadFull{
		ID:       u.ID,
		Username: u.Username,
		Email:    u.Email,
		Address:  u.Address,
		Phone:    u.Phone,
		Role:     u.Role,
		Country:  u.Country,
	}

	if u.MediaModel.Media != nil && u.MediaModel.Media.FileName != "" {
		userRead.MediaModel = &Media{FileName: u.MediaModel.Media.FileName, FileExtension: u.MediaModel.Media.FileExtension, BaseModel: BaseModel{
			ID: u.MediaModel.Media.GetID(),
		}}
	}

	if len(u.Guilds) > 0 {
		userRead.Guilds = make([]GuildRead, len(u.Guilds))
		for i, guild := range u.Guilds {
			userRead.Guilds[i] = guild.ToRead()
		}

	}

	return userRead
}

func (u User) IsOwner(userID uint) bool {
	return u.ID == userID
}

func (u User) ToReadWithImage() UserReadWithImage {
	return UserReadWithImage{
		ID:       u.ID,
		Username: u.Username,
		Email:    u.Email,
		Media:    u.MediaModel.Media,
		Score:    u.GlobalScore,
	}
}

func (u User) IsAdmin() bool {
	return u.Role == "admin"
}
