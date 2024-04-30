package models

import (
	"time"
)

type Match struct {
	BaseModel
	TournamentID     uint
	Tournament       Tournament `gorm:"foreignKey:TournamentID"`
	PlayerOneID      uint
	PlayerOne        User `gorm:"foreignKey:PlayerOneID"`
	PlayerTwoID      uint
	PlayerTwo        User `gorm:"foreignKey:PlayerTwoID"`
	StartTime        time.Time
	EndTime          time.Time
	Status           string `gorm:"default:started" validate:"required,eq=started|eq=finished"`
	WinnerID         *uint
	Winner           User    `gorm:"foreignKey:WinnerID"`
	Scores           []Score `gorm:"foreignKey:MatchID"`
	TournamentStepID uint
	TournamentStep   TournamentStep `gorm:"foreignKey:TournamentStepID"`
}

func (m Match) GetID() uint {
	return m.ID
}

func (m Match) GetTableName() string {
	return "matches"
}
