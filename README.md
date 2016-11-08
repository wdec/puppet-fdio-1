# fdio

#### Table of Contents
1. [Overview](#overview)
1. [Module Description](#module-description)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Reference ](#reference)
1. [Limitations](#limitations)
1. [Development](#development)
1. [Release Notes/Contributors](#release-notescontributors)

## Overview

Puppet module that installs and configures [FD.io][1] projects VPP and Honeycomb Agent.

## Module Description

Deploys FD.io projects to various OSs via package.

All configuration should be handled through the Puppet module's [params](#parameters).

## Setup

### What `fdio` affects

* [VPP][2], a packet processing platform.
* [Honeycomb][3], a management agent for VPP.

## Usage

The most basic usage, passing no parameters to the fdio class, will install and start VPP with a default configuration.

```puppet
class { 'fdio':
}
```

### Set uio-driver

To set the uio-driver use the `vpp_dpdk_uio_driver` param.

```puppet
class { 'fdio':
  vpp_dpdk_devs => ['0000:00:07.0'],
  vpp_dpdk_uio_driver => 'vfio_pci',
}
```

## Reference

### Classes

#### Public classes

* `::fdio`: Main entry point to the module.
* `::fdio::honeycomb`: Class to install and configure Honeycomb agent.

#### Private classes

* `::fdio::params`: Contains default class param values.
* `::fdio::install`: Installs VPP from packages.
* `::fdio::config`: Manages VPP startup config
* `::fdio::service`: Shuts down and disables kernel interfaces, starts VPP service and configuring VPP interfaces


#### Parameters

#### `::fdio`

##### `repo_branch`

FD.io repository branch name.

Default: `release`

Valid options: `release`, `master`, and branch name such as `stable.1609`.

##### `vpp_dpdk_devs`

PCI devices to bind to VPP.

Default: []

Valid options: list of PCI devices in the form of "DDDD:BB:SS.F"

##### `vpp_dpdk_uio_driver`

Sets the uio-driver for VPP

Default: `uio_pci_generic`

Valid options: `vfio-pci`, `uio_pci_generic` and `igb_uio`. Note that `igb_uio` must be already loaded in the kernel before this module is invoked.

##### `vpp_vlan_enabled`

Enabled vlan tagged traffic on VPP interfaces. This is needed to configure vlan_strip_offload option for Cisco VIC interfaces.

Default: `false`

Valid options: `true`, `false`

##### `vpp_cpu_main_core`
##### `vpp_cpu_corelist_worker`

VPP thread pinning configuration. Details about those options can be found [here][4].

Default: `undef`

Valid options: Same format as VPP startup config is accepted. Reference [here][4].

##### `vpp_cpu_corelist_worker`

Configures VPP interface with IP settings found on its corresponding kernel NIC.

Default: `true`

Valid options: `true`, `false`

#### `::fdio::honeycomb`

##### `rest_port`

Port for Honeycomb REST interface to listen on.

Default: `'8181'`

Valid options: Valid TCP port number.

##### `websocket_rest_port`

Port for Honeycomb REST interface to listen on for websocket connections.

Default: `'7779'`

Valid options: Valid TCP port number.

##### `user`

Username to configure in honeycomb

Default: `'admin'`

##### `password`

Password to configure in honeycomb

Default: `'admin'`

## Limitations

* Currently only works on Centos 7. Ubuntu support will be added in the future.

## Development

We welcome contributions and work to make them easy!

## Release Notes/Contributors


[1]: https://fd.io/
[2]: https://wiki.fd.io/view/VPP
[3]: https://wiki.fd.io/view/Honeycomb
[4]: https://wiki.fd.io/view/VPP/Command-line_Arguments#.22cpu.22_parameters