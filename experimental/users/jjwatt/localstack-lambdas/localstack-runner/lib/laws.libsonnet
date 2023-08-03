local awslib = import 'aws.libsonnet';
local util = import 'util.libsonnet';

local def_other_vars(localstack_hostname='localhost', localstack_edge_port='4566') = [
  ': "${LOCALSTACK_HOSTNAME:=%s}"' % localstack_hostname,
  ': "${LOCALSTACK_EDGE_PORT:=%s}"' % localstack_edge_port,
  ': "${ENDPOINT_URL:=http://${LOCALSTACK_HOSTNAME}:${LOCALSTACK_EDGE_PORT}}"',
];
// TODO: make this generate the '--env' lines from vars using docker_env_strings
local docker_run_laws() = [
  'docker run --network host',
  '--env "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"',
  '--env "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"',
  '--env "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}"',
  '--rm',
  '--mount type=bind,source="${DIR}",target=/workdir',
  'amazon/aws-cli',
  '--endpoint-url="${ENDPOINT_URL}" "$@"',
];

local docker_env_strings(obj) = [
  '--env "%s=%s' % [std.asciiUpper(i[0]), std.asciiUpper(i[0])]
  for i in util.obj_zip(obj)
];

local docker_run_laws_env_file() = [
  'docker run --network host',
  '--env-file "${ENV_FILE}"',
  '--rm',
  '--mount type=bind,source="${DIR}",target=/workdir',
  'amazon/aws-cli',
  '--endpoint-url="${ENDPOINT_URL}" "$@"',
];

local Script = {
  sh_header: '#!/bin/bash',
  sh_set_mode: 'set -euo pipefail',
  sh_this_script_dir: ': "${DIR:=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)}"',
  cmds: [self.sh_header, self.sh_set_mode, self.sh_this_script_dir],
};

local add_tab(str) = '\t' + str;
local add_tabs(strlist) = std.map(add_tab, strlist);

// TODO: Take aws config obj and localstack config obj
// Then check for the required keys
local LawsScript(aws_config) = Script {
  sh_aws_vars: awslib.env_list(aws_config),
  sh_run_laws: [std.join(' ', docker_run_laws())],
  sh_run_laws_env_file: [std.join(' ', docker_run_laws_env_file())],
  sh_other_vars: def_other_vars(),
  cmds+: self.sh_other_vars +
         ['if [[ -z ${ENV_FILE+x} ]]; then'] +
         add_tabs(self.sh_aws_vars) +
         add_tabs(self.sh_run_laws) +
         ['else'] +
         add_tabs(self.sh_run_laws_env_file) +
         ['fi'],
};

{
  local laws = self,
  LawsScript(config):: LawsScript(config),
  script(config):: laws.LawsScript(config).cmds,
}
