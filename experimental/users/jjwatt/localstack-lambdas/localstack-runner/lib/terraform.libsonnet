/* terraform.tf
 * Functions and templates for working with terraform,
 * especially for generating tf files for use with localstack.
 */

{
  local tf = self,
  default_aws_provider:: {
    source: 'hashicorp/aws',
    version: '~> 3.27',
  },
  EndpointsList:: [
    'apigateway',
    'cloudformation',
    'cloudwatch',
    'dynamodb',
    'es',
    'firehose',
    'iam',
    'kinesis',
    'lambda',
    'route53',
    'redshift',
    's3',
    'secretsmanager',
    'ses',
    'sns',
    'sqs',
    'ssm',
    'stepfunctions',
    'sts',
  ],
  ProviderEndpointsFromUrl(url):: {
    endpoints: {
      [k]: url
      for k in tf.EndpointsList
    },
  },
  ProviderEndpointsFromLocalStackConfig(config)::
    local url = 'http://' + config.localstack_hostname + ':' + config.localstack_edge_port;
    tf.ProviderEndpointsFromUrl(url),
  LocalStackDefaultTags:: {
    default_tags: { tags: { Environment: 'Localstack', Service: 'Testing' } },
  },
  LocalStackTerraform:: {
    terraform: {
      backend: {
        'local': {},
      },
      required_providers: {
        aws: tf.default_aws_provider,
      },
    },
  },
  LocalStackAwsProvider(config):: {
    provider: {
      aws: {
        // TODO: Can I get rid of needing the separate profile?
        profile: 'localstack',
        access_key: config.aws_access_key_id,
        secret_key: config.aws_secret_access_key,
        region: config.aws_default_region,
        s3_force_path_style: true,
        skip_credentials_validation: true,
        skip_metadata_api_check: true,
        skip_requesting_account_id: true,
      } + tf.ProviderEndpointsFromLocalStackConfig(config),
    },
  },
  LocalStackAwsProviderTfFile(config):: tf.LocalStackAwsProvider(config) + tf.LocalStackTerraform + tf.LocalStackDefaultTags,
}
