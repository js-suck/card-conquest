package models

import (
	"time"
)

const (
	TournamentStatusOpened   = "opened"
	TournamentStatusStarted  = "started"
	TournamentStatusFinished = "finished"
	TournamentStatusCanceled = "canceled"
)

type UserReadTournament struct {
	ID    uint   `gorm:"primarykey" json:",omitempty"`
	Name  string `json:"username"`
	Email string `json:"email"`
}

type GameReadTournament struct {
	ID   uint   `gorm:"primarykey"`
	Name string `json:"name"`
}

type CreateTournamentPayload struct {
	Name        string `form:"name" json:"name" validate:"required"`
	Description string `form:"description" json:"description" validate:"required"`
	Location    string `form:"location" json:"location"`
	UserID      uint   `form:"organizer_id" json:"organizer_id"`
	GameID      uint   `form:"game_id" json:"game_id" validate:"required"`
	StartDate   string `form:"start_date" json:"start_date" validate:"required"`
	EndDate     string `form:"end_date" json:"end_date" validate:"required"`
	Rounds      int    `form:"rounds" json:"rounds" validate:"required"`
	TagsIDs     []uint `form:"tags_ids" json:"tags_ids" validate:"required"`
	Image       []byte `gorm:"type:longblob" json:"-"`
	MaxPlayers  int    `form:"max_players" json:"max_players" validate:"required"`
}

type Tournament struct {
	BaseModel
	MediaModel
	Name        string           `json:"name" validate:"required"`
	Description string           `json:"description" validate:"required"`
	Location    string           `json:"location"`
	UserID      uint             `json:"organizer_id" `
	User        *User            `gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	GameID      uint             `json:"game_id" validate:"required"`
	Game        Game             `gorm:"foreignKey:GameID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	StartDate   string           `json:"start_date" validate:"required"`
	EndDate     string           `json:"end_date" validate:"required"`
	Status      string           `json:"status" gorm:"default:opened"`
	Users       []*User          `gorm:"many2many:user_tournaments;"`
	Tags        []*Tag           `json:"tags" gorm:"many2many:tag_tournaments;"`
	Rounds      int              `json:"rounds" validate:"required"`
	MaxPlayers  int              `json:"maxPlayers" validate:"required" example:"32"`
	Steps       []TournamentStep `json:"tournament_steps" gorm:"foreignKey:TournamentID"`
}

type TournamentRead struct {
	ID          uint               `json:"id"`
	Name        string             `json:"name"`
	Description string             `json:"description"`
	Location    string             `json:"location"`
	Organizer   UserReadTournament `json:",omitempty"`
	Game        GameReadTournament `json:"game"`
	StartDate   time.Time          `json:"start_date"`
	EndDate     time.Time          `json:"end_date"`
	Media       *Media             `json:"media, omitempty"`
	MaxPlayers  int                `json:"max_players"`
}

type NewTournamentPayload struct {
	Name        string    `json:"name" validate:"required" example:"Tournament 1" `
	Description string    `json:"description" example:"Tournament 1 description" validate:"required"`
	Location    string    `json:"location" example:"New York"`
	UserID      uint      `json:"organizer_id" example:"1" validate:"required"`
	GameID      uint      `json:"game_id" example:"1" validate:"required"`
	StartDate   time.Time `json:"start_date" validate:"required" example:"2024-04-12T00:00:00Z" format:"date-time"`
	EndDate     time.Time `json:"end_date" validate:"required" example:"2024-05-12T00:00:00Z" format:"date-time"`
	Rounds      int       `json:"rounds" validate:"required" example:"3"`
	TagsIDs     []uint    `json:"tags_idss" validate:"required"`
	MaxPlayers  int       `json:"max_players" validate:"required" example:"32"`
}

func (t Tournament) GetTableName() string {
	return "tournaments"
}

func (t Tournament) GetID() uint {
	return t.ID
}

func (t Tournament) ToRead() TournamentRead {
	obj := TournamentRead{
		ID:          t.ID,
		Name:        t.Name,
		Location:    t.Location,
		Description: t.Description,
		Game: GameReadTournament{
			ID:   t.Game.ID,
			Name: t.Game.Name,
		},
		StartDate: t.CreatedAt,
		EndDate:   t.UpdatedAt,
		Organizer: UserReadTournament{
			ID:    t.UserID,
			Name:  t.User.Username,
			Email: t.User.Email,
		},
		MaxPlayers: t.MaxPlayers,
	}

	if t.MediaModel.Media != nil {
		obj.Media = &Media{FileName: t.MediaModel.Media.FileName, FileExtension: t.MediaModel.Media.FileExtension, BaseModel: BaseModel{
			ID: t.MediaModel.Media.GetID(),
		}}
	}

	return obj

}
