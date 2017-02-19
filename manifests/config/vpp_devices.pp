# == Define: fdio::config::vpp_devices
#
# Defined type to configure device in VPP configuration file
#
# === Parameters:
# [*pci_address*]
# (required) The PCI address of the device.
#
define fdio::config::vpp_devices (
  $pci_address = $title
) {
  vpp_config {
    "dpdk/dev/${pci_address}": ensure => 'present';
  }
}