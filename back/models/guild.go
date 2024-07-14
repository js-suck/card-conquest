package models

import "gorm.io/gorm"

type Guild struct {
	MediaModel
	BaseModel
	ID          uint    `json:"id" gorm:"primaryKey"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Admins      *[]User `json:"admins" gorm:"many2many:user_admin_guilds;"`
	Players     *[]User `json:"players" gorm:"many2many:guild_players;"`
}

func (g *Guild) AfterFind(tx *gorm.DB) (err error) {
	tx.Model(g).Association("Media").Find(&g.Media)
	return
}

func (g Guild) IsOwner(userID uint) bool {
	for _, user := range *g.Admins {
		if user.ID == userID {
			return true
		}
	}
	return false
}

type GuildRead struct {
	ID          uint                `json:"id"`
	Name        string              `json:"name"`
	Description string              `json:"description"`
	Media       MediaModel          `json:"media"`
	Players     []UserReadWithImage `json:"players"`
}

func (g Guild) GetTableName() string {
	return "guilds"
}

func (g Guild) GetID() uint {
	return g.ID
}

func (g Guild) ToRead() GuildRead {

	gr := GuildRead{
		ID:          g.ID,
		Name:        g.Name,
		Description: g.Description,
	}

	if g.MediaModel.Media != nil {
		gr.Media = g.MediaModel
	}

	if g.Players != nil && len(*g.Players) > 0 {
		players := make([]UserReadWithImage, len(*g.Players))

		for i, player := range *g.Players {
			players[i] = player.ToReadWithImage()
		}

		gr.Players = players
	}

	return gr
}
