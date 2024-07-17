package db

import (
	"authentication-api/models"
	"fmt"
	"gorm.io/gorm"
)

var GamesFixtures = []models.Game{
	{
		BaseModel: models.BaseModel{},
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "mtg.jpg",
				FileExtension: "jpg",
			},
		},
		Name: "Magic: The Gathering",
	},
	{
		BaseModel: models.BaseModel{},
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "yugioh.jpeg",
				FileExtension: "jpeg",
			},
		},
		Name: "Yu-Gi-Oh!",
	},
	{
		BaseModel: models.BaseModel{},
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "heartsone.jpeg",
				FileExtension: "jpeg",
			},
		},
		Name: "Hearthstone",
	},
	{
		BaseModel: models.BaseModel{},
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "pokemon.jpeg",
				FileExtension: "jpeg",
			},
		},
		Name: "Pokémon TCG",
	},
	{
		BaseModel: models.BaseModel{},
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "gwent.jpeg",
				FileExtension: "jpeg",
			},
		},
		Name: "Gwent: The Witcher Card Game",
	},
	{
		BaseModel: models.BaseModel{},
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "legends_of_runeterra.jpeg",
				FileExtension: "jpeg",
			},
		},
		Name: "Legends of Runeterra",
	},
	{
		BaseModel: models.BaseModel{},
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "eternal.jpeg",
				FileExtension: "jpeg",
			},
		},
		Name: "Eternal Card Game",
	},
	{
		BaseModel: models.BaseModel{},
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "shadowverse.png",
				FileExtension: "png",
			},
		},
		Name: "Shadowverse",
	}, {
		BaseModel: models.BaseModel{},
		MediaModel: models.MediaModel{
			Media: &models.Media{
				FileName:      "one_piece.jpg",
				FileExtension: "jpg",
			},
		},
		Name: "One Piece Card Game",
	},
}

func insertGamesFixtures(db *gorm.DB) error {
	for _, game := range GamesFixtures {
		err := db.Create(&game).Error
		if err != nil {
			return fmt.Errorf("failed to insert game %s: %v", game.Name, err)
		}
	}
	return nil
}
