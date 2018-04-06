# == Class fdio::service
#
# Configure and start VPP service.
#
class fdio::service {
  service { 'vpp':
    ensure    => running,
    enable    => true,
    subscribe => Package['vpp'],
  }

  # Mop up vpp hugepages systemd config
  file { ['/etc/sysctl.d/80-vpp.conf']:
    ensure    => 'present',
    content  => '#CONFIG INTENTIONALLY EMPTY - Cisco VTS',
    subscribe => Package['vpp'],
  }
}

