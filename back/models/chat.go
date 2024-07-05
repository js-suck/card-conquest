package models

type ChatMessage struct {
	ID        uint `gorm:"primaryKey"`
	GuildId   int  `json:"guild_id" gorm:"column:guild_id"`
	UserId    int  `json:"user_id" gorm:"column:user_id"`
	Username  string
	Content   string
	Timestamp int64
}
