package models

type TournamentStep struct {
	BaseModel
	TournamentID uint
	Name         string
	Sequence     int
	Matches      []Match `gorm:"foreignKey:TournamentStepID"`
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
