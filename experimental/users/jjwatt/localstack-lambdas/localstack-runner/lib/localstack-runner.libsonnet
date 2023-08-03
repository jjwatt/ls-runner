local localstacklib = import 'localstack.libsonnet';

{
  localstack_config:: {
    local this = self,
    Services:: {
      services: localstacklib.ServicesList,
    },
    new(image='localstack/localstack',
        hostname='localstack',
        port='4566',
        docker_name='localstack-runner-main',
        docker_network='localstack',
        lambda_network='localstack',
        lambda_executor='docker-reuse',
        host_tmp_folder='/tmp/localstack',
        debug='1'): this.Services {
      image: image,
      localstack_hostname: hostname,
      localstack_edge_port: port,
      localstack_docker_name: docker_name,
      docker_network: docker_network,
      lambda_network: lambda_network,
      lambda_executor: lambda_executor,
      host_tmp_folder: host_tmp_folder,
      debug: debug,
    },
    DebugMixin:: {
      debug: '1',
    },
  },
  //localstack: $.localstack_config.new(),
}
