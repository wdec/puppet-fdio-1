# == Class: fdio
#
# Installs vpp and configures /etc/vpp/startup.conf
#
# === Parameters:
# [*repo_branch*]
#   (optional) fd.io repo branch.
#   Valid values are 'release', 'master' and stable branch like 'stable.1609'.
#   Defaults to 'release'.
#
# [*vpp_exec_commands*]
#   (optional) array of VPP startup exec commands
#   Defaults to undef
#
# [*vpp_exec_file*]
#   (optional) VPP startup exec file path. Existing config file will not be
#   overwritten, vpp_exec_commands will be appended.
#   Defaults to '/etc/vpp/vpp-exec'
#
# [*vpp_dpdk_support*]
#   (optional) Enable DPDK support for VPP
#   Defaults to true
#
# [*vpp_dpdk_devs*]
#   (optional) Array of PCI addresses to bind to vpp.
#   Defaults to undef.
#
# [*vpp_dpdk_uio_driver*]
#   (optional) VPP DPDK UIO driver type.
#   Defaults to undef
#
# [*vpp_dpdk_dev_default_options*]
#   (optional) VPP interface default options configuration.
#   This will configure dev default {options}. It should be a string
#   containing all of the desired options.
#   Example: 'vlan-strip-offload on num-rx-queues 3'
#   Default to undef.
#
# [*vpp_dpdk_socket_mem*]
#   (optional) DPDK hugepage memory allocation per socket.
#   Example: '1024,1024'
#   Default to undef.
#
# [*vpp_cpu_main_core*]
#   (optional) VPP main thread pinning core.
#   Defaults to undef (no pinning)
#
# [*vpp_cpu_corelist_workers*]
#   (optional) Comma separated list of cores for VPP worker thread pinning in
#   string format.
#   Example: '2,3'.
#   Defaults to undef (no pinning)
#
# [*vpp_vhostuser_coalesce_frames*]
#   (optional) vhost-user coalesce frames.
#   Example: 32
#   Defaults to undef
#
# [*vpp_vhostuser_coalesce_time*]
#   (optional) vhost-user coalesce time in seconds
#   Example: 0.005
#   Defaults to undef
#
# [*vpp_vhostuser_dont_dump_memory*]
#   (optional) vhost-user dont-dump-memory option. Avoids dumping vhost-user
#   shared memory segments to core files.
#   Defaults to true
#
# [*vpp_tuntap_enable*]
#   (optional) enable VPP tuntap driver
#   Valid values are true or false.
#   Defaults to undef
#
# [*vpp_tuntap_mtu*]
#   (optional) VPP tuntap interface MTU
#   Defaults to undef
#
# [*vpp_tapcli_mtu*]
#   (optional) VPP tapcli interface MTU
#   Defaults to undef
#
# [*copy_kernel_nic_ip*]
#   (optional) Configures VPP interface with IP settings found on its corresponding kernel NIC.
#   Defaults to true
#
# [*enable_core_dump*]
#   (optional) Enables VPP core-dump.
#   Defaults to true
#
# [*full_core_dump*]
#   (optional) Enables Full VPP core-dump not just text+data+bss
#   Defaults to false
#

class fdio (
  $repo_branch                    = $::fdio::params::repo_branch,
  $vpp_exec_commands              = $::fdio::params::vpp_exec_commands,
  $vpp_exec_file                  = $::fdio::params::vpp_exec_file,
  $vpp_dpdk_support               = $::fdio::params::vpp_dpdk_support,
  $vpp_dpdk_devs                  = $::fdio::params::vpp_dpdk_devs,
  $vpp_dpdk_uio_driver            = $::fdio::params::vpp_dpdk_uio_driver,
  $vpp_dpdk_dev_default_options   = $::fdio::params::vpp_dpdk_dev_default_options,
  $vpp_dpdk_socket_mem            = $::fdio::params::vpp_dpdk_socket_mem,
  $vpp_cpu_main_core              = $::fdio::params::vpp_cpu_main_core,
  $vpp_cpu_corelist_workers       = $::fdio::params::vpp_cpu_corelist_workers,
  $vpp_vhostuser_coalesce_frames  = $::fdio::params::vpp_vhostuser_coalesce_frames,
  $vpp_vhostuser_coalesce_time    = $::fdio::params::vpp_vhostuser_coalesce_time,
  $vpp_vhostuser_dont_dump_memory = $::fdio::params::vpp_vhostuser_dont_dump_memory,
  $vpp_tuntap_enable              = $::fdio::params::vpp_tuntap_enable,
  $vpp_tuntap_mtu                 = $::fdio::params::vpp_tuntap_mtu,
  $vpp_tapcli_mtu                 = $::fdio::params::vpp_tapcli_mtu,
  $copy_kernel_nic_ip             = $::fdio::params::copy_kernel_nic_ip,
  $enable_core_dump               = $::fdio::params::enable_core_dump,
  $full_coredump                  = $::fdio::params::full_coredump,
) inherits ::fdio::params {

  validate_array($vpp_dpdk_devs)

  # Validate OS family
  case $::osfamily {
    'RedHat': {}
    'Debian': {
        warning('Debian has limited support, is less stable, less tested.')
    }
    default: {
        fail("Unsupported OS family: ${::osfamily}")
    }
  }

  # Validate OS
  case $::operatingsystem {
    'centos', 'redhat': {
      if $::operatingsystemmajrelease != '7' {
        # RHEL/CentOS versions < 7 not supported as they lack systemd
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    'fedora': {
      # Fedora distros < 23 are EOL as of 2016-07-19
      # https://fedoraproject.org/wiki/End_of_life
      if $::operatingsystemmajrelease < '23' {
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    'ubuntu': {
      if $::operatingsystemmajrelease != '16.04' {
        fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
      }
    }
    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }

  group {'vpp':
    ensure => present,
    gid => $fdio::params::default_gid_number,
  }

  if $enable_core_dump or $full_coredump {
    limits::fragment {
      'vpp/soft/core': value => 'unlimited';
      'vpp/hard/core': value => 'unlimited';
    }
  }

  class { '::fdio::install': }
  -> class { '::fdio::config': }
  ~> class { '::fdio::service': }
  -> Class['::fdio']

}
