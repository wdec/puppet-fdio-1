require 'spec_helper'

describe 'fdio::honeycomb' do
  let(:facts) {{
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'CentOS',
      :operatingsystemmajrelease => '7',
  }}

  let(:pre_condition) { 'include fdio' }

  it { should compile }
  it { should compile.with_all_deps }
  it { should contain_class('fdio::honeycomb') }
  it { should contain_class('fdio::install').that_comes_before('Class[fdio::config]') }
  it { should contain_package('honeycomb').that_requires('Package[vpp]') }
  it { should contain_augeas('credential.json').that_requires('Package[honeycomb]') }
  it { should contain_augeas('credential.json').that_comes_before('Service[honeycomb]') }
  it { should contain_augeas('restconf.json').that_requires('Package[honeycomb]') }
  it { should contain_augeas('restconf.json').that_comes_before('Service[honeycomb]') }
  it { should contain_service('honeycomb').that_requires('Package[honeycomb]') }
  it { should contain_service('honeycomb').that_requires('Service[vpp]') }

  it { should contain_augeas('credential.json').with(
    'lens' => 'Json.lns',
    'incl' => '/opt/honeycomb/config/credentials.json',
    )
  }
  it { should contain_augeas('restconf.json').with(
    'lens' => 'Json.lns',
    'incl' => '/opt/honeycomb/config/restconf.json',
    )
  }
  it { should contain_service('honeycomb').with(
    'ensure' => 'running',
    'enable' => 'true',
    )
  }
end
