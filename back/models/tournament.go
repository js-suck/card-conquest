package models

import "time"

const (
	TournamentStatusCreated  = "created"
	TournamentStatusStarted  = "started"
	TournamentStatusFinished = "finished"
	TournamentStatusCanceled = "canceled"
)

type UserReadTournament struct {
	ID    uint   `gorm:"primarykey"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

type GameReadTournament struct {
	ID   uint   `gorm:"primarykey"`
	Name string `json:"name"`
}

type Tournament struct {
	BaseModel
	MediaModel
	Name        string  `json:"name" validate:"required"`
	Description string  `json:"description" validate:"required"`
	Location    string  `json:"location"`
	UserID      uint    `json:"organizer_id" `
	User        *User   `gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	GameID      uint    `json:"game_id" validate:"required"`
	Game        Game    `gorm:"foreignKey:GameID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	StartDate   string  `json:"start_date" validate:"required"`
	EndDate     string  `json:"end_date" validate:"required"`
	Status      string  `json:"status" gorm:"default:created"`
	Users       []*User `gorm:"many2many:user_tournaments;"`
	Rounds      int     `json:"rounds" validate:"required"`
}

type TournamentRead struct {
	ID          uint               `json:"id"`
	Name        string             `json:"name"`
	Description string             `json:"description"`
	Location    string             `json:"location"`
	Organizer   UserReadTournament `json:"organizer"`
	Game        GameReadTournament `json:"game"`
	StartDate   time.Time          `json:"start_date"`
	EndDate     time.Time          `json:"end_date"`
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
}

func (t Tournament) GetTableName() string {
	return "tournaments"
}

func (t Tournament) GetID() uint {
	return t.ID
}

func (t Tournament) ToRead() TournamentRead {
	return TournamentRead{
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
	}
}
