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
) {

  include ::fdio

  package { 'honeycomb':
    ensure  => present,
    require => Package['vpp'],
  }
  ->
  # Configuration of Honeycomb
  file { 'honeycomb.json':
    ensure  => file,
    path    => '/opt/honeycomb/config/honeycomb.json',
    # Set user:group owners
    owner   => 'honeycomb',
    group   => 'honeycomb',
    # Use a template to populate the content
    content => template('fdio/honeycomb.json.erb'),
  }
  ~>
  service { 'honeycomb':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [ Service['vpp'], Package['honeycomb'] ],
    restart    => 'systemctl stop vpp;systemctl stop honeycomb;rm -rf /var/lib/honeycomb/persist/*;systemctl start vpp; sleep 5;systemctl start honeycomb',
  }

  if !empty($opendaylight_ip) {
    validate_ip_address($opendaylight_ip)

    $fdio_data = "{'node' : [{'node-id':'${node_id}','netconf-node-topology:host':'${bind_ip}','netconf-node-topology:port':'2831','netconf-node-topology:tcp-only':false,'netconf-node-topology:keepalive-delay':0,'netconf-node-topology:username':'${opendaylight_username}','netconf-node-topology:password':'${opendaylight_password}','netconf-node-topology:connection-timeout-millis':10000,'netconf-node-topology:default-request-timeout-millis':10000,'netconf-node-topology:max-connection-attempts':10,'netconf-node-topology:between-attempts-timeout-millis':10000,'netconf-node-topology:schema-cache-directory':'hcmount'}]}"
    $fdio_url = "http://${opendaylight_ip}:${opendaylight_port}/restconf/config/network-topology:network-topology/network-topology:topology/topology-netconf/node/${node_id}"

    exec { 'VPP Mount into ODL':
      command   => "curl -o /dev/null --fail --silent -u ${opendaylight_username}:${opendaylight_password} ${fdio_url} -i -H 'Content-Type: application/json' --data \"${fdio_data}\" -X PUT",
      tries     => 5,
      try_sleep => 30,
      path      => '/usr/sbin:/usr/bin:/sbin:/bin',
      require   => Service['honeycomb'],
    }
  }
}
