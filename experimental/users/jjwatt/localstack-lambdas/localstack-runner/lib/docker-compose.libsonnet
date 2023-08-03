{
  local Version = { version: '3.8' },
  local dc = self,
  DefaultExternalNetwork(name):: {
    networks: {
      default: {
        external: {
          name: name,
        },
      },
    },
  },
  Service(name, container_name='', image='', ports=[], environment=[], volumes=[]):: {
    [name]: {
      container_name: container_name,
      image: image,
      ports: ports,
      environment: environment,
      volumes: volumes,
    },
  },
  Port(internal, external=''):: {
    internal:: internal,
    external:: if external == '' then internal else external,
    port_str: '%s:%s' % [self.internal, self.external],
  },
  local str_to_port(str) =
    local port_parts = std.splitLimit(str, ':', 1);
    if std.length(port_parts) < 2 then $.Port(port_parts[0]) else $.Port(port_parts[0], port_parts[1]),
  WithPort(port):: {
    ports+: [$.BuildPort(port).port_str],
  },
  BuildPort(port)::
    local passed_str = if std.isString(port) then port;
    local passed_obj = if std.isObject(port) then if std.objectHas(port, 'internal') then port;
    assert passed_str != null || passed_obj != null;
    local passed_port = if passed_obj != null then passed_obj else str_to_port(passed_str);
    passed_port,
  WithPorts(ports):: {
    ports+: [$.BuildPort(x).port_str for x in ports],
  },
  DockerCompose(name):: Version + $.DefaultExternalNetwork(name) {
    services: {} + $.Service(name),
  },
}
