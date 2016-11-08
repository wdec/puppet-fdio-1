Puppet::Type.type(:vpp_service).provide :vpp do

  commands :vppctlcmd => "vppctl"
  commands :systemctlcmd => "systemctl"

  def get_int_prefix(name)
    if %r{([[:alpha:]]*#{name})\s+} =~ `vppctl show int`
      return $1
    else
      raise Puppet::Error.new("Cannot find vpp interface matching: #{name}")
    end
  end

  def convert_pci_addr(pci_dev)
    if pci_dev =~ /\p{XDigit}+:(\p{XDigit}+):(\p{XDigit}+)\.(\p{XDigit}+)/
      return "%x/%x/%x" % ["0x#{$1}".hex, "0x#{$2}".hex, "0x#{$3}".hex]
    else
      raise Puppet::Error.new("Incorrect pci dev format: #{pci_dev}")
    end
  end

  def vpp_pre_config
    @resource[:pci_devs].each do |pci_dev|
      Facter.value(:interfaces).split(',').each do |kernel_nic|
        if pci_dev == `ethtool -i #{kernel_nic} | grep bus-info | awk '{print $2}'`.strip
          unless system("ip link set dev #{kernel_nic} down")
            raise Puppet::Error.new("Failed to shut down kernel nic #{kernel_nic}")
          end

          #Disable NIC on boot
          file_data = ""
          onboot_exists = false
          if File.exist?("/etc/sysconfig/network-scripts/ifcfg-#{kernel_nic}")
            IO.foreach("/etc/sysconfig/network-scripts/ifcfg-#{kernel_nic}") do |line|
              if /ONBOOT/.match(line)
                onboot_exists = true
                file_data += "ONBOOT=no\n"
              else
                file_data += line
              end
            end
            unless onboot_exists
              file_data += "ONBOOT=no"
            end
            File.open("/etc/sysconfig/network-scripts/ifcfg-#{kernel_nic}", "w") {|file| file.puts file_data}
          end

          if Facter.value("ipaddress_#{kernel_nic}")
            @int_ip_mapping[pci_dev] = Facter.value("ipaddress_#{kernel_nic}") + "/" + Facter.value("netmask_#{kernel_nic}")
          end
        end
      end
    end
  end

  def configure_vpp_interfaces
    @resource[:pci_devs].each do |pci_dev|
      vpp_int_name= get_int_prefix(convert_pci_addr(pci_dev))
      vppctlcmd "set int state", vpp_int_name, @resource[:state]
      if @resource[:copy_kernel_nic_ip] && @int_ip_mapping.has_key?(pci_dev)
        vppctlcmd "set int ip address", vpp_int_name, @int_ip_mapping[pci_dev]
      end
    end
  end

  def create
    @int_ip_mapping = {}
    vpp_pre_config

    #Bring up VPP service
    systemctlcmd "restart", "vpp"
    systemctlcmd "enable", "vpp"
    sleep 10
    systemctlcmd "is-active", "vpp"
    systemctlcmd "is-enabled", "vpp"

    #Configure VPP interfaces
    configure_vpp_interfaces
  end

  def destroy
    systemctlcmd "stop", "vpp"
    systemctlcmd "disable", "vpp"
  end

  def exists?
    if system("systemctl is-active vpp --quiet")
      @resource[:pci_devs].each do |pci_dev|
        int_name_str = convert_pci_addr(pci_dev)
        if %r{([[:alpha:]]*#{int_name_str})\s+} !~ `vppctl show int`
          return false
        end
      end
    else
      return false
    end
    return true
  end

  def state
    @resource[:pci_devs].each do |pci_dev|
      vpp_int_output = `vppctl show int #{get_int_prefix(convert_pci_addr(pci_dev))}`
      if ! /\s+up\s+/.match(vpp_int_output)
        return "down"
      end
    end
    return "up"
  end

  def state=(value)
    @resource[:pci_devs].each do |pci_dev|
      vppctlcmd "set int state", get_int_prefix(convert_pci_addr(pci_dev)), value
    end
  end
end