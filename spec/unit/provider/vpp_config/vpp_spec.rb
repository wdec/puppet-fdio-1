require 'puppet'
require 'puppet/provider/vpp_config/vpp'
require 'spec_helper'

provider_class = Puppet::Type.type(:vpp_config).provider(:vpp)

describe 'Puppet::Type.type(:vpp_config).provider(:vpp)' do

  let :vpp_attrs do
    {
      :setting => 'dpdk/dev/0000:00:07.0',
      :ensure  => 'present',
    }
  end

  let :resource do
    Puppet::Type::Vpp_config.new(vpp_attrs)
  end

  let :provider do
    provider_class.new(resource)
  end

  describe 'on create' do
    it 'should call add_setting' do
      provider.expects(:add_setting)
      provider.create
    end
  end

  describe "when changing value" do
    it 'should change value' do
      provider.expects(:add_setting).with('vlan-strip-offload on')
      provider.value = 'vlan-strip-offload on'
    end
  end
end