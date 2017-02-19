require 'spec_helper'

describe 'fdio::honeycomb' do
  let(:facts) {{
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'CentOS',
      :operatingsystemmajrelease => '7',
  }}

  it { should compile }
  it { should compile.with_all_deps }
  it { should contain_class('fdio::honeycomb') }
  it { should contain_class('fdio::install').that_comes_before('Class[fdio::config]') }
  it { should contain_package('honeycomb').that_requires('Package[vpp]') }
  it { should contain_file('honeycomb.json').that_requires('Package[honeycomb]') }
  it { should contain_file('honeycomb.json').that_notifies('Service[honeycomb]') }
  it { should contain_service('honeycomb').that_requires('Package[honeycomb]') }
  it { should contain_service('honeycomb').that_requires('Service[vpp]') }

  it { should contain_file('honeycomb.json').with(
    'ensure'  => 'file',
    'path'    => '/opt/honeycomb/config/honeycomb.json',
    'owner'   => 'honeycomb',
    'group'   => 'honeycomb',
    )
  }
  it { should contain_service('honeycomb').with(
    'ensure'     => 'running',
    'enable'     => 'true',
    )
  }
end
