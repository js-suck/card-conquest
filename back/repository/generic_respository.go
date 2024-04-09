package repository

import "database/sql"

type GenericRepository[t any] struct {
	db        *sql.DB
	tableName string
}

func NewGenericRepository[T any](db *sql.DB, tableName string) *GenericRepository[T] {
	return &GenericRepository[T]{
		db: db, tableName: tableName,
	}
}
