package models

import "gorm.io/gorm"

type Guild struct {
	MediaModel
	BaseModel
	ID          uint    `json:"id" gorm:"primaryKey"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Admins      *[]User `json:"admins" gorm:"many2many:user_admin_guilds; constraint:OnDelete:CASCADE;"`
	Players     *[]User `json:"players" gorm:"many2many:guild_players; constraint:OnDelete:CASCADE;"`
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
	Admins      []UserReadWithImage `json:"admins"`
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

	if g.Admins != nil && len(*g.Admins) > 0 {
		admins := make([]UserReadWithImage, len(*g.Admins))

		for i, admin := range *g.Admins {
			admins[i] = admin.ToReadWithImage()
		}

		gr.Admins = admins

	}

	return gr
}
