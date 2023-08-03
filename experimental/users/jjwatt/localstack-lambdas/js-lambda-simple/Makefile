.PHONY: stop logs network start startd healthcheck

DOCKER_FLAGS := --env-file localstack.envrc
AWSCLI ?= ./laws

# FUNCTION := $(shell basename "$(PWD)")
FUNCTION := localstack-lambda-js-hello
COMMIT := $(shell git rev-parse --short HEAD)
RUNTIME := nodejs12.x
BIN_DIR ?= dist
# ARCHIVE := $(addsuffix -$(COMMIT).zip,$(FUNCTION))
# Not using this yet. Building the zip in tf.
ARCHIVE := $(FUNCTION).zip

start: .network-touchfile
	docker-compose $(DOCKER_FLAGS) up
startd: .network-touchfile
	docker-compose $(DOCKER_FLAGS) up -d
stop:
	docker-compose $(DOCKER_FLAGS) down
logs:
	docker-compose $(DOCKER_FLAGS) logs

# Create a custom docker network
# This makes using lambdas a little easier
# When lambda code needs to reach other Localstack AWS services,
# it can use this URL: http://localstack:4566
.network-touchfile:
	# TODO(jjwatt): bad. fix this to only create the touch if it exists.
	docker network create localstack || true
	touch .network-touchfile
network: .network-touchfile
.init-terraform-touchfile:
	terraform init
	touch .init-terraform-touchfile
terraform-init: .init-terraform-touchfile
healthcheck:
	curl http://localhost:4566/health\?reload -s | jq .
lambda-list-functions:
	$(AWSCLI) lambda list-functions

## build: builds the go lambda function
build: clean
	mkdir -p $(BIN_DIR)
	# zip -r9jT $(BIN_DIR)/$(ARCHIVE) $(BIN_DIR)/$(FUNCTION)
	@echo "JS does not need to build. Zip file is built by terraform into $(BIN_DIR)"

## clean: Clean the dist folder
clean:
	rm -f $(BIN_DIR)/$(FUNCTION) $(BIN_DIR)/*.zip tfplan
