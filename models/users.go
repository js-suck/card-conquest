package models

type User struct {
	ID       uint   `json:"id"`
	Username string `json:"username"`
	Password string `json:"password"`
}

type NewUserToken struct {
	Username string `json:"username"`
	Password string `json:"password"`
}
