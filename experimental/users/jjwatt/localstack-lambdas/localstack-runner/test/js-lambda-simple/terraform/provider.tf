terraform {
  backend "local" {
    # Could get cute and put it in the localstack s3 at some point
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  # TODO(jjwatt): Make this 0.15+ to try out test provider
  required_version = ">= 0.14.9"
}

provider "aws" {
  # I need this for now. Create an aws profile
  # in your ~/.aws/credentials or ~/.aws/config
  # with the same values as below.
  # profile = "localstack"
  # I need to look at the documentation to see if there's
  # a better way.
  profile = "localstack"

  # Somewhere on the localstack repo README.md, it says to make these 'test' so
  # that "s3 pre-sign works correctly."
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = var.localstack_url
    cloudformation = var.localstack_url
    cloudwatch     = var.localstack_url
    dynamodb       = var.localstack_url
    es             = var.localstack_url
    firehose       = var.localstack_url
    iam            = var.localstack_url
    kinesis        = var.localstack_url
    lambda         = var.localstack_url
    route53        = var.localstack_url
    redshift       = var.localstack_url
    s3             = var.localstack_url
    secretsmanager = var.localstack_url
    ses            = var.localstack_url
    sns            = var.localstack_url
    sqs            = var.localstack_url
    ssm            = var.localstack_url
    stepfunctions  = var.localstack_url
    sts            = var.localstack_url
  }

  default_tags {
    tags = {
      Environment = "Localstack"
      Service     = "Testing"
    }
  }
}
