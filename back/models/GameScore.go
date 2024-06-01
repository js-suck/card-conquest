package models

type GameScore struct {
	BaseModel
	GameID     uint `json:"game_id"`
	Game       Game `gorm:"foreignKey:GameID" json:"-"`
	UserID     uint `json:"user_id"`
	User       User `gorm:"foreignKey:UserID" json:"-"`
	TotalScore int  `json:"score"`
}
