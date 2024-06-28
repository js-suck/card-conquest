package models

import (
	"authentication-api/errors"
)

type TournamentStep struct {
	BaseModel
	TournamentID uint
	Tournament   Tournament `gorm:"foreignKey:TournamentID" json:"-"`
	Name         string
	Sequence     int
	Matches      []Match `gorm:"foreignKey:TournamentStepID"`
}

func (t TournamentStep) ApplyReadPermissions() errors.IError {
	//TODO implement me
	panic("implement me")
}

func (t TournamentStep) ApplyWritePermissions() errors.IError {
	//TODO implement me
	panic("implement me")
}

func (t TournamentStep) ApplyUpdatePermissions() errors.IError {
	//TODO implement me
	panic("implement me")
}

func (t TournamentStep) ApplyDeletePermissions() errors.IError {
	//TODO implement me
	panic("implement me")
}

func (t TournamentStep) GetID() uint {
	return t.ID
}

func (t TournamentStep) GetTableName() string {
	return "tournament_steps"
}

type MatchReadTournamentStep struct {
	Name     string
	Sequence int
}
