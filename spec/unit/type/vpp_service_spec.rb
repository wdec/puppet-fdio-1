require 'puppet'
require 'puppet/type/vpp_service'
require 'spec_helper'

describe 'Puppet::Type.type(:neutron_config)' do

  before :each do
    @vpp_service = Puppet::Type.type(:vpp_service).new(:name => 'vpp service config')
  end

  it 'should have default values' do
    expect(@vpp_service[:state]).to eq(:up)
    expect(@vpp_service[:copy_kernel_nic_ip]).to eq(:true)
  end

  it 'should accept a single pci dev' do
    Puppet::Type.type(:vpp_service).new(:name => 'vpp service config', :pci_devs => '0000:00:07.0')
  end

  it 'should accept array of pci devs' do
    Puppet::Type.type(:vpp_service).new(:name => 'vpp service config', :pci_devs => ['0000:00:07.0', '0000:00:08.0'])
  end

  it 'should not accept invalid pci dev format' do
    expect {
      Puppet::Type.type(:vpp_service).new(:name => 'vpp service config', :pci_devs => ['0/7/0', '0000:00:08.0'])
    }.to raise_error(Puppet::Error, /Incorrect PCI dev address/)
  end

  it 'should accept valid states' do
    @vpp_service[:state] = :up
    expect(@vpp_service[:state]).to eq(:up)
    @vpp_service[:state] = :down
    expect(@vpp_service[:state]).to eq(:down)
  end

  it 'should not accept invalid state' do
    expect {
      @vpp_service[:state] = :shut
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

  it 'should accept valid copy_kernel_nic_ip' do
    @vpp_service[:copy_kernel_nic_ip] = :true
    expect(@vpp_service[:copy_kernel_nic_ip]).to eq(:true)
    @vpp_service[:copy_kernel_nic_ip] = :false
    expect(@vpp_service[:copy_kernel_nic_ip]).to eq(:false)
  end

  it 'should not accept invalid copy_kernel_nic_ip' do
    expect {
      @vpp_service[:copy_kernel_nic_ip] = :yes
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

end
