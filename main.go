package main

import "authentication-api/routers"

func main() {

	r := routers.SetupRouter()

	r.Run(":8080")
}
