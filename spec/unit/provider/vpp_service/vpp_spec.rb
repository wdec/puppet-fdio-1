require 'puppet'
require 'puppet/provider/vpp_service/vpp'
require 'spec_helper'

provider_class = Puppet::Type.type(:vpp_service).provider(:vpp)

describe 'Puppet::Type.type(:vpp_service).provider(:vpp)' do

  let :vpp_attrs do
    {
      :name               => 'vpp service config',
      :pci_devs           => '0000:00:07.0',
      :ensure             => 'present',
      :state              => 'up',
      :copy_kernel_nic_ip => 'false',
    }
  end

  let :resource do
    Puppet::Type::Vpp_service.new(vpp_attrs)
  end

  let :provider do
    provider_class.new(resource)
  end

  describe 'on create' do
    it 'should call service restart' do
      provider.expects(:vpp_pre_config)
      provider.expects(:configure_vpp_interfaces)
      provider.expects(:systemctlcmd).with('restart', 'vpp')
      provider.expects(:systemctlcmd).with('enable', 'vpp')
      provider.expects(:systemctlcmd).with('is-enabled', 'vpp')
      provider.expects(:systemctlcmd).with('is-active', 'vpp')
      provider.create
    end
  end

  describe "when changing state" do
    it 'should change state' do
      provider.stubs(:get_int_prefix).returns('GigabitEthernet0/7/0')
      provider.expects(:vppctlcmd).with('set int state', 'GigabitEthernet0/7/0', 'down')
      provider.state = 'down'
    end
  end
end