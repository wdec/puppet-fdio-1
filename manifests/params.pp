# == Class fdio::params
#
# This class manages the default params for the fdio class.
#
class fdio::params {
  $repo_branch = 'release'
  $vpp_exec_commands = undef
  $vpp_exec_file = '/etc/vpp/vpp-exec'
  $vpp_dpdk_support = true
  $vpp_dpdk_devs = []
  $vpp_dpdk_uio_driver = undef
  $vpp_dpdk_dev_default_options = 'num-rx-queues 1 num-tx-queues 2'
  $vpp_dpdk_socket_mem = '510,510'
  $vpp_cpu_main_core = undef
  $vpp_cpu_corelist_workers = undef
  $vpp_vhostuser_coalesce_frames = '32'
  $vpp_vhostuser_coalesce_time = '2e-3'
  $vpp_vhostuser_dont_dump_memory = true
  $vpp_tuntap_enable = undef
  $vpp_tuntap_mtu = undef
  $vpp_tapcli_mtu = undef
  $copy_kernel_nic_ip = true
  $enable_core_dump = true
  $default_gid_number = 799
  $full_coredump = false
  $coredump_size = 'unlimited'
}
