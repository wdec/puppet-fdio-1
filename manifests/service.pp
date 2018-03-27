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

  # Mop up vpp hugepages and systemd config, until it's fixed by RPM package
  file { ['/etc/sysctl.d/80-vpp.conf', '/etc/sysctl.d/81-hugepages.conf']:
    ensure    => absent,
    subscribe => Package['vpp'],
  }

  exec { 'Reload sysctl config':
    command     => 'sysctl --system',
    path        => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
    refreshonly => true,
    subscribe   => [
      File['/etc/sysctl.d/80-vpp.conf'],
      File['/etc/sysctl.d/81-hugepages.conf'],
    ]
  }
}

