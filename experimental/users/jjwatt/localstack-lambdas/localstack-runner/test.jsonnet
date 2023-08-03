local awslib = import 'aws.libsonnet';
local dcompose = import 'docker-compose.libsonnet';
local laws = import 'laws.libsonnet';
local config = import 'localstack-runner.json';
local lsconfig_gen = import 'localstack-runner.libsonnet';
local localstacklib = import 'localstack.libsonnet';
local tf = import 'terraform.libsonnet';
local util = import 'util.libsonnet';

{
  local this = self,
  aws: awslib.new() + config.aws,
  aws_env_list: awslib.env_list(this.aws),
  assert awslib.env_list(this.aws) == util.env_strings(this.aws),
  localstack: localstacklib.LocalstackConfig(config.localstack),
  localstack_from_gen: localstacklib.LocalstackConfig(lsconfig_gen.localstack_config.new()),
  // localstack_env_list: util.env_strings(this.localstack),
  docker_compose_native: localstacklib.DockerCompose(this.localstack),
  docker_compose_native_from_lsgen: localstacklib.DockerCompose($.localstack_from_gen),
  docker_compose_yaml: std.manifestYamlDoc(localstacklib.DockerCompose(this.localstack)),
  // endpoints_test: tf.ProviderEndpointsFromUrl('http://localstack:4566'),
  tf_provider_file_test: tf.LocalStackAwsProviderTfFile(this.aws + this.localstack),
  docker_compose_services_withports: dcompose.WithPorts(['1234', '5678']),
  // laws_script: laws.script(this.aws),
}
