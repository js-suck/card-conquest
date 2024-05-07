package models

type Game struct {
	BaseModel
	MediaModel
	Name string `json:"name"`
}

func (g Game) GetTableName() string {
	return "games"
}

func (g Game) GetID() uint {
	return g.ID
}

func (g Game) ToRead() interface{} {
	return nil
}
