package models

type FeatureFlag struct {
	Enabled bool   `json:"enabled"`
	Name    string `json:"name"`
}
