package models

type Media struct {
	BaseModel
	FileName      string
	FileExtension string
}

func (m Media) GetID() uint {
	return m.ID
}

func (m Media) GetTableName() string {
	return "medias"
}
