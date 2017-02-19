require 'puppet'
require 'puppet/type/vpp_config'
require 'spec_helper'

describe 'Puppet::Type.type(:vpp_config)' do

  before :each do
    @vpp_conf = Puppet::Type.type(:vpp_config).new(:setting => 'dpdk/test_setting')
  end

  it 'should accept value' do
    Puppet::Type.type(:vpp_config).new(:setting => 'dpdk/test_setting', :value => 'test_value')
  end

end
