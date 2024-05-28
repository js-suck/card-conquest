package models

type Score struct {
	BaseModel
	MatchID  uint
	Match    Match `gorm:"foreignKey:MatchID"`
	PlayerID uint
	Player   User `gorm:"foreignKey:PlayerID"`
	Score    int
}

type ScoreRead struct {
	PlayerID uint
	Score    int
}
