# == Class: honeycomb
#
# OpenDaylight Honeycomb Agent
#
# === Parameters:
# [*opendaylight_ip*]
#   (optional) Opendaylight server IP used to bind VPP to Opendaylight.
#   Defaults to ''
#
# [*opendaylight_port*]
#   (optional) Opendaylight server Port.
#   Defaults to '8081'
#
# [*opendaylight_username*]
#   (optional) Opendaylight server user name.
#   Defaults to 'admin'
#
# [*opendaylight_password*]
#   (optional) Opendaylight server password.
#   Defaults to 'admin'
#
# [*rest_port*]
#   Port for Honeycomb REST interface to listen on.
#
# [*websocket_rest_port*]
#   Port for Honeycomb REST interface to listen on for websocket connections.
#
# [*user*]
#   Username to configure in honeycomb.
#
# [*password*]
#   Password to configure in honeycomb.
#
# [*bind_ip*]
#   (optional) Honeycomb service binding IP
#   Defaults to '127.0.0.1'
#
# [*node_id*]
#   (optional) Node ID for binding VPP to Opendaylight
#   Defaults to $::fqdn
#
# [*interface_role_map*]
#   (optional) List of interface role mapping in the format
#              of <VPP interface name>:<role name>
#   Example:
#      [ 'GigabitEthernet0/5/0:public-interface',
#        'GigabitEthernet0/6/0:tenant-interface' ]
#   Defaults to undef
#
class fdio::honeycomb (
  $opendaylight_ip       = '',
  $opendaylight_port     = '8081',
  $opendaylight_username = 'admin',
  $opendaylight_password = 'admin',
  $rest_port             = '8181',
  $websocket_rest_port   = '7779',
  $user                  = 'admin',
  $password              = 'admin',
  $bind_ip               = '127.0.0.1',
  $node_id               = $::fqdn,
  $interface_role_map    = [],
) {

  validate_array($interface_role_map)

  package { 'honeycomb':
    ensure  => present,
    require => Package['vpp'],
  }

  # Configuration of Honeycomb
  augeas { 'credential.json':
    lens    => 'Json.lns',
    incl    => '/opt/honeycomb/config/credentials.json',
    changes => [
      "set /files/opt/honeycomb/config/credentials.json/dict/entry[. = 'username']/string ${user}",
      "set /files/opt/honeycomb/config/credentials.json/dict/entry[. = 'password']/string ${password}",
    ],
    require => Package['honeycomb'],
    before  => Service['honeycomb'],
  }
  augeas { 'restconf.json':
    lens    => 'Json.lns',
    incl    => '/opt/honeycomb/config/restconf.json',
    changes => [
      "set /files/opt/honeycomb/config/restconf.json/dict/entry[. = 'restconf-binding-address']/string ${bind_ip}",
      "set /files/opt/honeycomb/config/restconf.json/dict/entry[. = 'restconf-https-binding-address']/string ${bind_ip}",
      "set /files/opt/honeycomb/config/restconf.json/dict/entry[. = 'restconf-port']/number ${rest_port}",
      "set /files/opt/honeycomb/config/restconf.json/dict/entry[. = 'restconf-websocket-port']/number ${websocket_rest_port}",
    ],
    require => Package['honeycomb'],
    before  => Service['honeycomb'],
  }

  service { 'honeycomb':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [ Service['vpp'], Package['honeycomb'] ],
  }

  if !empty($opendaylight_ip) {
    validate_ip_address($opendaylight_ip)
    $odl_url = "http://${opendaylight_ip}:${opendaylight_port}"
    $fdio_data = "{'node' : [{'node-id':'${node_id}','netconf-node-topology:host':'${bind_ip}','netconf-node-topology:port':'2831','netconf-node-topology:tcp-only':false,'netconf-node-topology:keepalive-delay':0,'netconf-node-topology:username':'${opendaylight_username}','netconf-node-topology:password':'${opendaylight_password}','netconf-node-topology:connection-timeout-millis':10000,'netconf-node-topology:default-request-timeout-millis':10000,'netconf-node-topology:max-connection-attempts':10,'netconf-node-topology:between-attempts-timeout-millis':10000}]}"
    $fdio_url = "${odl_url}/restconf/config/network-topology:network-topology/network-topology:topology/topology-netconf/node/${node_id}"
    $oper_mount_url = "${odl_url}/restconf/operational/renderer:renderers"

    exec { 'VPP Mount into ODL':
      command   => "curl -o /dev/null --fail --silent -u ${opendaylight_username}:${opendaylight_password} ${fdio_url} -i -H 'Content-Type: application/json' --data \"${fdio_data}\" -X PUT",
      tries     => 5,
      try_sleep => 30,
      path      => '/usr/sbin:/usr/bin:/sbin:/bin',
      require   => Service['honeycomb'],
    }
    -> exec { 'Check VPP was mounted into ODL operational DS':
      command   => "curl --fail -u ${opendaylight_username}:${opendaylight_password} ${oper_mount_url} | grep ${node_id}",
      tries     => 5,
      try_sleep => 30,
      path      => '/usr/sbin:/usr/bin:/sbin:/bin',
    }

    if !empty($interface_role_map) {
      fdio::honeycomb::configure_role_mappings { $interface_role_map:
        honeycomb_username => $user,
        honeycomb_password => $password,
        honeycomb_url      => "http://${bind_ip}:${rest_port}",
        require            => Service['honeycomb'],
        before             => Exec['VPP Mount into ODL'],
      }
    }
  }
}
