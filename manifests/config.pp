# == Class fdio::config
#
# This class handles fdio config changes.
#
class fdio::config {
  file { '/etc/vpp/startup.conf':
    content => template('fdio/startup.conf.erb'),
  }

  # ensure that dpdk module is loaded
  exec { 'insert_dpdk_kmod':
    command => "modprobe ${::fdio::vpp_dpdk_uio_driver}",
    unless  => "lsmod | grep ${::fdio::vpp_dpdk_uio_driver}",
    path    => '/bin:/sbin',
  }
}
