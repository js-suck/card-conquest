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
	Media *Media `json:"media"`
}

type GameReadTournament struct {
	ID   uint   `gorm:"primarykey"`
	Name string `json:"name"`
}

type CreateTournamentPayload struct {
	Name        string  `form:"name" json:"name" validate:"required"`
	Description string  `form:"description" json:"description" validate:"required"`
	Location    string  `form:"location" json:"location"`
	UserID      uint    `form:"organizer_id" json:"organizer_id"`
	GameID      uint    `form:"game_id" json:"game_id" validate:"required"`
	StartDate   string  `form:"start_date" json:"start_date" validate:"required"`
	EndDate     string  `form:"end_date" json:"end_date" validate:"required"`
	Rounds      int     `form:"rounds" json:"rounds" validate:"required"`
	TagsIDs     []uint  `form:"tags_ids" json:"tags_ids" validate:"required"`
	Image       []byte  `gorm:"type:longblob" json:"-"`
	MaxPlayers  int     `form:"max_players" json:"max_players" validate:"required"`
	Longitude   float64 `form:"longitude" json:"longitude"`
	Latitude    float64 `form:"latitude" json:"latitude"`
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
	Longitude   float64          `json:"longitude"`
	Latitude    float64          `json:"latitude"`
	Subscribers []User           `gorm:"many2many:tournament_subscribers;"`
}

func (t Tournament) New() IModel {
	return &Tournament{}
}

type TournamentRead struct {
	ID                uint                 `json:"id"`
	Name              string               `json:"name"`
	Description       string               `json:"description"`
	Location          string               `json:"location"`
	Organizer         UserReadTournament   `json:",omitempty"`
	Game              GameReadTournament   `json:"game"`
	StartDate         time.Time               `json:"start_date"`
	EndDate           time.Time               `json:"end_date"`
	Media             *Media               `json:"media, omitempty"`
	Rounds            int                  `json:"rounds"`
	MaxPlayers        int                  `json:"max_players"`
	PlayersRegistered int                  `json:"players_registered"`
	Status            string               `json:"status"`
	Longitude         float64              `json:"longitude"`
	Latitude          float64              `json:"latitude"`
	Players           []UserReadTournament `json:"players"`
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

	startDate, err := time.Parse(time.RFC3339, t.StartDate)
	if err != nil {
		// Gestion de l'erreur si la conversion échoue
		// Vous pouvez choisir de gérer cela comme vous le souhaitez
	}

	endDate, err := time.Parse(time.RFC3339, t.EndDate)
	if err != nil {
		// Gestion de l'erreur si la conversion échoue
		// Vous pouvez choisir de gérer cela comme vous le souhaitez
	}
	obj := TournamentRead{
		ID:          t.ID,
		Name:        t.Name,
		Location:    t.Location,
		Description: t.Description,
		Game: GameReadTournament{
			ID:   t.Game.ID,
			Name: t.Game.Name,
		},
		StartDate: startDate,
		EndDate:   endDate,
		Organizer: UserReadTournament{
			ID:    t.UserID,
			Name:  t.User.Username,
			Email: t.User.Email,
		},
		Rounds:            t.Rounds,
		MaxPlayers:        t.MaxPlayers,
		PlayersRegistered: len(t.Users),
		Status:            t.Status,
		Longitude:         t.Longitude,
		Latitude:          t.Latitude,
	}

	if t.MediaModel.Media != nil {
		obj.Media = &Media{FileName: t.MediaModel.Media.FileName, FileExtension: t.MediaModel.Media.FileExtension, BaseModel: BaseModel{
			ID: t.MediaModel.Media.GetID(),
		}}
	}
	if t.Users != nil && len(t.Users) > 0 {
		players := make([]UserReadTournament, len(t.Users))

		for i, player := range t.Users {
			players[i] = UserReadTournament{
				ID:    player.ID,
				Name:  player.Username,
				Email: player.Email,
			}

			if player.MediaModel.Media != nil {
				players[i].Media = player.MediaModel.Media
			}
		}

		obj.Players = players
	}
	return obj

}

func (t Tournament) IsOwner(userID uint) bool {
	return t.UserID == userID
}

type UpdateTournamentPayload struct {
	Name        string  `json:"name" example:"Tournament 1" form:"name"`
	Description string  `json:"description" example:"Tournament 1 description" form:"description"`
	Location    string  `json:"location" example:"New York" form:"location"`
	UserID      uint    `json:"organizer_id" example:"1" form:"organizer_id"`
	GameID      uint    `json:"game_id" example:"1" form:"game_id"`
	StartDate   string  `json:"start_date" json:"start_date" form:"start_date"`
	EndDate     string  `json:"end_date" json:"end_date" form:"end_date"`
	Status      string  `json:"status" form:"status"`
	Rounds      int     `json:"rounds" example:"3" form:"rounds"`
	TagsIDs     []uint  `json:"tags_idss" form:"tags_ids"`
	MaxPlayers  int     `json:"max_players" example:"32" form:"max_players"`
	Longitude   float64 `json:"longitude" form:"longitude"`
	Latitude    float64 `json:"latitude" form:"latitude"`
	Image       []byte  `gorm:"type:longblob" json:"-"`
}
