# == Class fdio::config
#
# This class handles fdio config changes.
#
class fdio::config {

  if $fdio::vpp_dpdk_support {
    # ensure that dpdk module is loaded
    $dpdk_pmd_real = regsubst($fdio::vpp_dpdk_uio_driver, '-', '_', 'G')
    exec { 'insert_dpdk_kmod':
      command => "modprobe ${fdio::vpp_dpdk_uio_driver}",
      unless  => "lsmod | grep ${dpdk_pmd_real}",
      path    => '/bin:/sbin',
    }

    vpp_config {
      'dpdk/dev/default': value => $fdio::vpp_dpdk_dev_default_options;
      'dpdk/uio-driver': value => $fdio::vpp_dpdk_uio_driver;
      'dpdk/socket-mem': value => $fdio::vpp_dpdk_socket_mem;
    }

    fdio::config::vpp_devices {  $fdio::vpp_dpdk_devs: }
  }

  vpp_config {
    'vhost-user/coalesce-frames': value => $fdio::vpp_vhostuser_coalesce_frames;
    'vhost-user/coalesce-time': value => $fdio::vpp_vhostuser_coalesce_time;
    'tuntap/mtu': value => $fdio::vpp_tuntap_mtu;
    'tapcli/mtu': value => $fdio::vpp_tapcli_mtu;
  }

  if $fdio::vpp_vhostuser_dont_dump_memory {
    vpp_config {
      'vhost-user/dont-dump-memory': ensure => present;
    }
  }

  if $fdio::vpp_tuntap_enable != undef {
    if $fdio::vpp_tuntap_enable {
      vpp_config {
        'tuntap/enable': ensure => present;
        'tuntap/disable': ensure => absent;
      }
    }
    else {
      vpp_config {
        'tuntap/enable': ensure => absent;
        'tuntap/disable': ensure => present;
      }
    }
  }

  if !empty($fdio::vpp_exec_commands) {
    file { $fdio::vpp_exec_file:
      ensure => present,
    }
    fdio::config::vpp_exec_line { $fdio::vpp_exec_commands:
      path => $fdio::vpp_exec_file,
    }
    vpp_config {
      'unix/exec': value => $fdio::vpp_exec_file;
    }
  }

  vpp_config {
    'cpu/main-core': value => $fdio::vpp_cpu_main_core;
    'cpu/corelist-workers': value =>  join(any2array($fdio::vpp_cpu_corelist_workers), ',');
  }
}
