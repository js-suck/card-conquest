package models

type Tag struct {
	BaseModel
	Label       string        `json:"label" validate:"required"`
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

func (t Tag) New() IModel {
	return Tag{}
}

type NewTagPayload struct {
	Label string `json:"label" validate:"required"`
}

func (m Tag) IsOwner(userID uint) bool {
	return true
}
