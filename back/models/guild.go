package models

type Guild struct {
	MediaModel
	BaseModel
	ID          uint    `json:"id" gorm:"primaryKey"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Admins      *[]User `json:"admin" gorm:"many2many:user_admin_guilds;"`
	Users       *[]User `json:"users" gorm:"many2many:user_guilds;"`
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
	ID          uint       `json:"id"`
	Name        string     `json:"name"`
	Description string     `json:"description"`
	Media       MediaModel `json:"media"`
}

func (g Guild) GetTableName() string {
	return "guilds"
}

func (g Guild) GetID() uint {
	return g.ID
}

func (g Guild) ToRead() GuildRead {
	return GuildRead{
		ID:          g.ID,
		Name:        g.Name,
		Description: g.Description,
		Media:       g.MediaModel,
	}
}
