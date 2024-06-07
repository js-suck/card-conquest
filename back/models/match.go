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
	Status           string `gorm:"default:created" validate:"required,eq=started|eq=finished|eq=created"`
	WinnerID         *uint
	Winner           User    `gorm:"foreignKey:WinnerID"`
	Scores           []Score `gorm:"foreignKey:MatchID"`
	TournamentStepID uint
	TournamentStep   TournamentStep `gorm:"foreignKey:TournamentStepID"`
	MatchPosition    int            `gorm:"default:0"`
	Location         string
}

type MatchRead struct {
	ID             uint
	Tournament     TournamentRead    `gorm:"foreignKey:TournamentID"`
	PlayerOne      UserReadWithImage `gorm:"foreignKey:PlayerOneID"`
	PlayerTwo      UserReadWithImage `gorm:"foreignKey:PlayerTwoID"`
	StartTime      time.Time
	EndTime        time.Time
	TournamentStep MatchReadTournamentStep `gorm:"foreignKey:TournamentStepID"`
	MatchPosition  int                     `gorm:"default:0"`
	Scores         []ScoreRead             `gorm:"foreignKey:MatchID"`
	Status         string                  `gorm:"default:created" validate:"required,eq=started|eq=finished|eq=created"`
	Winner         UserReadTournament      `gorm:"foreignKey:WinnerID"`
	Location       string
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
	matchReads := MatchRead{
		ID: m.ID,
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
		PlayerOne: m.PlayerOne.ToReadWithImage(),
		PlayerTwo: m.PlayerTwo.ToReadWithImage(),
		TournamentStep: MatchReadTournamentStep{
			Name:     m.TournamentStep.Name,
			Sequence: m.TournamentStep.Sequence,
		},
		Winner:    m.Winner.ToRead(),
		StartTime: m.StartTime,
		EndTime:   m.EndTime,
		Status:    m.Status,
		Location:  m.Location,
	}

	if m.Scores != nil && len(m.Scores) > 0 {
		matchReads.Scores = make([]ScoreRead, len(m.Scores))
		for i, score := range m.Scores {
			matchReads.Scores[i] = ScoreRead{
				PlayerID: score.PlayerID,
				Score:    score.Score,
			}
		}
	}

	return matchReads

}

func (m Match) IsOwner(userID uint) bool {
	return true
}
