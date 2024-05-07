package models

type Tag struct {
	BaseModel
	Label       string        `json:"name" validate:"required"`
	Tournaments []*Tournament `gorm:"many2many:tag_tournaments;"`
	Games       []*Game       `gorm:"many2many:tag_games;"`
}

type CreateTagPayload struct {
	Label string `json:"label" validate:"required"`
}

func (t Tag) GetID() uint {
	return t.ID
}

func (t Tag) GetTableName() string {
	return "tags"
}

type NewTagPayload struct {
	Label string `json:"label" validate:"required"`
}
