# == Class: honeycomb
#
# OpenDaylight Honeycomb Agent
#
# === Parameters:
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
class fdio::honeycomb (
  $rest_port           = '8181',
  $websocket_rest_port = '7779',
  $user                = 'admin',
  $password            = 'admin',
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
    require    => [ Vpp_service['vpp'], Package['honeycomb'] ],
    restart    => 'systemctl stop vpp;systemctl stop honeycomb;rm -rf /var/lib/honeycomb/persist/*;systemctl start vpp; sleep 5;systemctl start honeycomb',
  }

}
