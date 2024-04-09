package handlers_test

import (
	"fmt"
	"slices"
	"strings"
	"testing"
)

func fullFillSlice(s []string) []string {
	for i := 0; i < 8; i++ {
		text := "aaa"
		s = append(s, text)

	}
	return s
}

func filterFunc(s string) bool {

	return strings.Contains(s, "e")
}

func TestSlice(t *testing.T) {

	var sString []string

	newSlice := fullFillSlice(sString)

	fmt.Print(newSlice)

	slices.DeleteFunc(newSlice, filterFunc)

	fmt.Print(newSlice)

}
