Puppet::Type.newtype(:vpp_service) do

  ensurable

  newparam(:name) do
  end

  newparam(:pci_devs, :array_matching => :all) do
    desc "PCI dev addresses to be bound to VPP"
    def insync?(is)
      is.sort == should.sort
    end

    validate do |values|
      values = [values] unless values.is_a?(Array)
      values.map! do |value|
        if value =~ /\p{XDigit}+:(\p{XDigit}+):(\p{XDigit}+)\.(\p{XDigit}+)/
          value
        else
          raise(Puppet::Error, "Incorrect PCI dev address #{value}")
        end
      end
    end

    munge do |values|
      if values.is_a?(Array)
        values
      else
        [values]
      end
    end
  end

  newproperty(:state) do
    desc "VPP interface state"
    defaultto :up
    newvalues(:up, :down)
  end

  newparam(:copy_kernel_nic_ip) do
    desc "Whether to configure VPP interface with kernel NIC's IP settings"
    defaultto :true
    newvalues(:true, :false)
  end

end
