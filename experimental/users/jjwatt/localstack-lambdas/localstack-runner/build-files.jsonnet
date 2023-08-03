// build-files.jsonnet

// Import configuration used to generate other files.
local awslib = import 'aws.libsonnet';
local laws = import 'laws.libsonnet';
local config = import 'localstack-runner.json';
local localstack = import 'localstack.libsonnet';
local tf = import 'terraform.libsonnet';

local LocalstackConfig = localstack.LocalstackConfig(config.localstack);

// Use awslib's AwsConfig base to make sure the config has the bare
// minimum of needed keys.
local AwsConfig = awslib.AwsConfig + config.aws;
local LawsConfig = AwsConfig;

//local DockerComposeConfig
//local LawsConfig
// TODO: Make this use the same env def generator as aws.libsonnet
{
  'localstack.envrc': |||
    DEBUG=%(debug)s
    TMPDIR=%(tmpdir)s
    SERVICES=%(services)s
    LAMBDA_EXECUTOR=%(lambda_executor)s
    LAMBDA_DOCKER_NETWORK=%(lambda_docker_network)s
    LOCALSTACK_DOCKER_NAME=%(localstack_docker_name)s
    LOCALSTACK_HOSTNAME=%(localstack_hostname)s
    LOCALSTACK_EDGE_PORT=%(localstack_edge_port)s
    HOST_TMP_FOLDER=%(host_tmp_folder)s
    LOCALSTACK_IMAGE=%(image)s
  ||| % LocalstackConfig,
  laws: std.lines(laws.script(LawsConfig)),
  'aws.envrc': std.lines(awslib.env_list(AwsConfig)),
  'docker-compose.yml': std.manifestYamlDoc(localstack.DockerCompose(LocalstackConfig), true),
  'provider.tf.json': std.manifestJsonEx(tf.LocalStackAwsProviderTfFile(AwsConfig + LocalstackConfig), '  '),
}
