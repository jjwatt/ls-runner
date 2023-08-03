.PHONY: all stop logs network start startd healthcheck clean genconfig debug test-jsonnet

# External programs
JSONNET ?= jsonnet
JQ ?= jq
DOCKER_COMPOSE ?= docker-compose

LOCALSTACK_RUNNER_JSON ?= localstack-runner.json
LOCALSTACK_ENV_FILE ?= localstack.envrc
LAWS_SCRIPT ?= laws
AWS_ENV_FILE ?= aws.envrc
DOCKER_FLAGS = --env-file $(LOCALSTACK_ENV_FILE)
AWSCLI ?= ./$(LAWS_SCRIPT)
LOCALSTACK_HOSTNAME ?= $(shell cat $(LOCALSTACK_RUNNER_JSON) | jq '.localstack.localstack_hostname')
LOCALSTACK_EDGE_PORT ?= $(shell cat $(LOCALSTACK_RUNNER_JSON) | jq '.localstack.localstack_edge_port')
genfiles = $(LOCALSTACK_ENV_FILE) $(LAWS_SCRIPT) $(AWS_ENV_FILE) terraform/provider.tf.json

define build-files
  @echo Creating $@...
  $(JSONNET) -J lib -S -m . ./build-files.jsonnet
endef

all: $(genfiles) test-jsonnet

start: docker-compose.yml network $(LOCALSTACK_ENV_FILE)
	$(DOCKER_COMPOSE) $(DOCKER_FLAGS) up
startd: docker-compose.yml network
	$(DOCKER_COMPOSE) $(DOCKER_FLAGS) up -d
stop:
	$(DOCKER_COMPOSE) $(DOCKER_FLAGS) down
logs:
	$(DOCKER_COMPOSE) $(DOCKER_FLAGS) logs
clean:
	rm $(genfiles)
test-jsonnet: build-files.jsonnet lib/*.libsonnet
	$(JSONNET) -J lib ./test.jsonnet
$(LAWS_SCRIPT): build-files.jsonnet lib/*.libsonnet
	$(build-files)
	chmod +x laws
$(AWS_ENV_FILE): build-files.jsonnet lib/*.libsonnet
	$(build-files)
$(LOCALSTACK_ENV_FILE): build-files.jsonnet lib/*.libsonnet
	$(build-files)
terraform/provider.tf.json: build-files.jsonnet lib/*.libsonnet
	$(build-files)
	mv provider.tf.json terraform/provider.tf.json
docker-compose.yml: build-files.jsonnet lib/*.libsonnet
	$(build-files)
genconfig: $(genfiles)

debug:
	$(info LOCALSTACK_HOSTNAME=$(LOCALSTACK_HOSTNAME))
# Create a custom docker network
# This makes using lambdas a little easier
# When lambda code needs to reach other Localstack AWS services,
# it can use this URL: http://localstack:4566
.network-touchfile:
	docker network inspect localstack || docker network create localstack
	touch $@
network: .network-touchfile
healthcheck:
	curl http://$(LOCALSTACK_HOSTNAME):$(LOCALSTACK_EDGE_PORT)/health\?reload -s | jq .
lambda-list-functions:
	$(AWSCLI) lambda list-functions

