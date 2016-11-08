# == Class fdio::service
#
# Configure and start VPP service.
#
class fdio::service {
  vpp_service { 'vpp' :
    ensure             => present,
    pci_devs           => $::fdio::vpp_dpdk_devs,
    state              => 'up',
    copy_kernel_nic_ip => $::fdio::copy_kernel_nic_ip,
  }
}

