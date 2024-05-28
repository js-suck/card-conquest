package models

import (
	"time"
)

type Match struct {
	BaseModel        ``
	TournamentID     uint
	Tournament       Tournament `gorm:"foreignKey:TournamentID"`
	PlayerOneID      uint       `gorm:"column:player_one_id"`
	PlayerOne        User       `gorm:"foreignKey:PlayerOneID"`
	PlayerTwoID      *uint      `gorm:"column:player_two_id"`
	PlayerTwo        User       `gorm:"foreignKey:PlayerTwoID"`
	StartTime        time.Time
	EndTime          time.Time
	Status           string `gorm:"default:started" validate:"required,eq=started|eq=finished"`
	WinnerID         *uint
	Winner           User    `gorm:"foreignKey:WinnerID"`
	Scores           []Score `gorm:"foreignKey:MatchID"`
	TournamentStepID uint
	TournamentStep   TournamentStep `gorm:"foreignKey:TournamentStepID"`
	MatchPosition    int            `gorm:"default:0"`
}

type MatchRead struct {
	Tournament     TournamentRead `gorm:"foreignKey:TournamentID"`
	PlayerOne      UserRead       `gorm:"foreignKey:PlayerOneID"`
	PlayerTwo      UserRead       `gorm:"foreignKey:PlayerTwoID"`
	StartTime      time.Time
	EndTime        time.Time
	TournamentStep MatchReadTournamentStep `gorm:"foreignKey:TournamentStepID"`
	MatchPosition  int                     `gorm:"default:0"`
	Scores         []ScoreRead             `gorm:"foreignKey:MatchID"`
}

func (m Match) GetID() uint {
	return m.ID
}

func (m Match) GetTableName() string {
	return "matches"
}

func (m Match) ToRead() MatchRead {
	scores := make([]ScoreRead, len(m.Scores))
	for _, score := range m.Scores {
		scores = append(scores, ScoreRead{
			PlayerID: score.PlayerID,
			Score:    score.Score,
		})
	}
	return MatchRead{
		Tournament: TournamentRead{
			ID:          m.Tournament.ID,
			Name:        m.Tournament.Name,
			Description: m.Tournament.Description,
			Location:    m.Tournament.Location,
			Game: GameReadTournament{
				ID:   m.Tournament.GameID,
				Name: m.Tournament.Name,
			},
			Media: nil,
		},
		PlayerOne: UserRead{
			ID:       m.PlayerOne.ID,
			Username: m.PlayerOne.Username,
		},
		PlayerTwo: UserRead{
			ID:       m.PlayerTwo.ID,
			Username: m.PlayerTwo.Username,
		},
		TournamentStep: MatchReadTournamentStep{
			Name:     m.TournamentStep.Name,
			Sequence: m.TournamentStep.Sequence,
		},
		Scores: scores,
	}
}
