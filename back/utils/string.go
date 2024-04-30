package utils

import "math/rand"

func GenerateRandomString(i int) string {
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	b := make([]byte, i)
	for i := range b {
		b[i] = charset[rand.Intn(len(charset))]
	}
	return string(b)

}
