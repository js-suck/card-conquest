package models

type FeatureFlag struct {
	ID      uint   `gorm:"primaryKey" json:"id"`
	Enabled bool   `json:"enabled"`
	Name    string `json:"name"`
}
