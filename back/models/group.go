package models

type Group struct {
	ID           uint
	TournamentID uint
	Name         string
	Description  string
}

type UserGroup struct {
	UserID  uint
	GroupID uint
}
