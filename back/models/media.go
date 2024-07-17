package models

type Media struct {
	BaseModel
	FileName      string `json:"file_name, omitempty"`
	FileExtension string `json:"file_extension, omitempty"`
}

func (m Media) GetID() uint {
	return m.ID
}

func (m Media) GetTableName() string {
	return "medias"
}

func (m Media) IsOwner(userID uint) bool {
	return true
}

func (m Media) New() IModel {
	return Media{}
}
