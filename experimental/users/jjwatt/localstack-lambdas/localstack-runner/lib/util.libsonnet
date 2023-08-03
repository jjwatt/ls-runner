/*
  util.libsonnet: shared utilities for configs with jsonnet
*/
{
  local util = self,
  env_strings(obj)::
    ['%s=%s' % [std.asciiUpper(i[0]), i[1]] for i in util.obj_zip(obj)],
  obj_zip(obj)::
    [[k, obj[k]] for k in std.objectFields(obj)],
  array_to_string(arr)::
    if std.type(arr) == 'array' then std.join(',', arr) else arr,
}
