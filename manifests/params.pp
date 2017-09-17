# == Class fdio::params
#
# This class manages the default params for the fdio class.
#
class fdio::params {
  $repo_branch = 'release'
  $vpp_dpdk_support = true
  $vpp_dpdk_devs = []
  $vpp_dpdk_uio_driver = 'uio_pci_generic'
  $vpp_dpdk_dev_default_options = undef
  $vpp_dpdk_socket_mem = undef
  $vpp_cpu_main_core = undef
  $vpp_cpu_corelist_workers = undef
  $copy_kernel_nic_ip = true
}
