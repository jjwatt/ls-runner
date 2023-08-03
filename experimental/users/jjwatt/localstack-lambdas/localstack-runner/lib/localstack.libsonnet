// localstack.libsonnet

local dcompose = import 'docker-compose.libsonnet';
local util = import 'util.libsonnet';

local services_as_string(config) = {
  services: util.array_to_string(config.services),
};

{
  ServicesList:: [
    // Services to tell localstack to start. There may be other valid ones--
    // for now, I'm just adding the ones I need for lambdas.
    'iam',
    'cloudwatch',
    'lambda',
    'apigateway',
    's3',
    'sns',
    'sqs',
    'dynamodb',
  ],
  LocalstackService(config):: dcompose.Service('localstack',
                                               container_name=config.localstack_docker_name,
                                               image=config.image),
  LocalstackConfig(config): config + services_as_string(config),
  local config_or_env(o, f, env_var) = '%s=%s' % [
    env_var,
    if std.objectHas(o, f) then o[f] else '${%s- }' % env_var,
  ],
  DockerCompose(config):: dcompose.DockerCompose(config.localstack_hostname) {
    local conf = $.LocalstackConfig(config),
    services+: $.LocalstackService(conf) {
      [conf.localstack_hostname]+: dcompose.WithPort(conf.localstack_edge_port) + dcompose.WithPort('4561') {
        environment+: [
          'SERVICES=%s' % conf.services,
          'DEBUG=%s' % conf.debug,
          config_or_env(conf, 'data_dir', 'DATA_DIR'),
          config_or_env(conf, 'lambda_executor', 'LAMBDA_EXECUTOR'),
          'DOCKER_HOST=%s' % 'unix:///var/run/docker.sock',
          config_or_env(conf, 'host_tmp_folder', 'HOST_TMP_FOLDER'),
        ],
        volumes+: [
          '%s:/tmp/localstack' % if std.objectHas(conf, 'host_tmp_folder') then conf.host_tmp_folder else '/tmp/localstack',
          '/var/run/docker.sock:/var/run/docker.sock',
        ],
      },
    },
  },
}
