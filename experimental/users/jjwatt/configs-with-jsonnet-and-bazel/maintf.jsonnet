
local env_yml = import "env.json";

// App is an object for defining app specific values, and for
// pulling things out for local {} and variable {} blocks.
local App = {
  app_name: '',
  environment: '',
  // Handle separating 'saas-dev' or 'saas-prod' into tokens, e.g.: ['saas', 'dev']
  count_env_tokens:: std.length(std.split(self.environment, "-")),
  env_tokens:: if self.count_env_tokens > 0 then std.splitLimit(self.environment, "-", 1),
  sub_env:: if self.count_env_tokens > 0 then self.env_tokens[self.count_env_tokens - 1],
  instance: "${terraform.workspace} == 'default' ? '' : ${terraform.workspace}",
};

// ThisEnvYml Mixin holds environment junk from `env.yml`.
local ThisEnvYml = {
  env_garbage: env_yml[self.environment][self.sub_env],
};

// makeApp builds an App object.
local makeApp(app_name="", environment="saas-dev") =
  App {
    environment: environment,
    app_name: app_name,
  } + ThisEnvYml;

// makeLocals makes a top-level locals {} block for terraform.
local makeLocals(app) =
  // Just give it everything for now.
  app;

// aws_tags_fields is a list of fields used for the "aws_tags" module.
local aws_tags_fields = [
  "source",
  "business_group", "business_cost_centre",
  "business_project", "business_owner_email", "business_owner_slack_channel",
  "infrastructure_build_id", "infrastructure_cluster", "infrastructure_environment",
  "infrastructure_role", "infrastructure_repository", "infrastructure_version",
  "security_compliance", "security_confidentiality", "security_encryption"
];

local RealTimeDataStoreApp = makeApp(app_name="real-time-data-store", environment="saas-dev");

// Output
{
  "//": "Generated by jsonnet. You probably don't want to edit by hand.",
  debugging: RealTimeDataStoreApp,
  terraform: {
    backend: {
      'local': {},
    },
    required_providers: {
      aws: {
        source: 'hashicorp/aws',
        version: '3.20.1',
      },
    },
  },
  locals: makeLocals(RealTimeDataStoreApp),
  data: [
    {
      aws_caller_identity: {
        caller_identity: {},
      },
    },
    {
      aws_arn: {
        caller_arn: {
          arn: '${data.aws_caller_identity.caller_identity.arn}',
        },
      },
    },
  ],
  module: {
    aws_tags: {
      source: "git@github.com:Guaranteed-Rate/terraform-aws-tags.git?ref=v1.7.0",
      business_group: "product-platform-services",
      business_project: RealTimeDataStoreApp.app_name,
    }
  }
}
