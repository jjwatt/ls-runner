
dcconfig=docker-compose.yml

dockercompose() {
	docker-compose "$@"
}

@test "Container starts up"
	docker-compose up
