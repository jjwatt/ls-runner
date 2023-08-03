// aws.libsonnet

local util = import 'util.libsonnet';

local default_region = 'us-east-1';
local default_access_key_id = 'test';
local default_secret_access_key = 'test';
local default_output = 'json';

local BaseConfig = {
  aws_access_key_id: error "AwsConfig must have 'aws_access_key_id'",
  aws_default_region: default_region,
  aws_default_output: default_output,
  secret_from_access_key:: self.aws_access_key_id,
};

local EnsureSecretAccessKey = {
  local config = self,
  aws_secret_access_key: super.secret_from_access_key_id,
};

{
  AwsConfig: BaseConfig + EnsureSecretAccessKey,
  new(aws_access_key_id=default_access_key_id,
      aws_secret_access_key=default_secret_access_key,
      aws_default_region=default_region,
      aws_default_output=default_output): self.AwsConfig {
    aws_access_key_id: aws_access_key_id,
    aws_secret_access_key: aws_secret_access_key,
    aws_default_region: aws_default_region,
    aws_default_output: aws_default_output,
  },
  env_list(config)::
    util.env_strings(config),
}
