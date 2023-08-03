
COMMIT := $(shell git rev-parse --short HEAD)
FUNCTION ?= localstack-lambda-js-hello
BIN_DIR ?= dist
RUNTIME := nodejs12.x
LAMBDA_HANDLER := main.handler
TERRAFORM ?= terraform
AWSCLI ?= ../laws

# AWS_SHARED_CREDENTIALS_FILE is an env var supported by
# the terraform AWS provider for providing credentials.
# This has a "localstack" profile built-in
# that matches the mock values used by my
# localstack setup in this repo.
AWS_SHARED_CREDENTIALS_FILE ?= ../dot-aws-config

plan:
	AWS_SHARED_CREDENTIALS_FILE=$(AWS_SHARED_CREDENTIALS_FILE) \
				    $(TERRAFORM) plan -out=tfplan \
		-var=function_name=$(FUNCTION) \
		-var=lambda_handler=$(LAMBDA_HANDLER)

apply:
	AWS_SHARED_CREDENTIALS_FILE=$(AWS_SHARED_CREDENTIALS_FILE) \
				    $(TERRAFORM) apply -auto-approve tfplan
destroy:
	AWS_SHARED_CREDENTIALS_FILE=$(AWS_SHARED_CREDENTIALS_FILE) \
				    $(TERRAFORM) destroy -auto-approve
show-plan: tfplan
	$(TERRAFORM) show -json tfplan
lambda-check:
	$(AWSCLI) lambda get-function --function-name $(FUNCTION)
lambda-invoke:
	$(AWSCLI) lambda invoke --function-name $(FUNCTION) /dev/stdout

