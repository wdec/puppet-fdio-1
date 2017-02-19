# == Class fdio::service
#
# Configure and start VPP service.
#
class fdio::service {
  service { 'vpp' :
    ensure => running,
    enable => true,
  }
}
