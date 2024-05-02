package models

type Game struct {
	BaseModel
	MediaModel
	Name        string       `json:"name"`
	Tournaments []Tournament `json:"-" gorm:"foreignKey:GameID"`
}

type GameRead struct {
	ID    uint   `json:"id"`
	Name  string `json:"name"`
	Media *Media `json:"media, omitempty"`
}

type GameRead struct {
	ID    uint   `json:"id"`
	Name  string `json:"name"`
	Media *Media `json:"media, omitempty"`
}

func (g Game) GetTableName() string {
	return "games"
}

func (g Game) GetID() uint {
	return g.ID
}

func (g Game) ToRead() GameRead {
	obj := GameRead{
		ID:   g.ID,
		Name: g.Name,
	}

	if g.MediaModel.Media != nil {
		obj.Media = &Media{FileName: g.MediaModel.Media.FileName, FileExtension: g.MediaModel.Media.FileExtension, BaseModel: BaseModel{
			ID: g.MediaModel.Media.GetID(),
		}}
	}

	return obj
}
