require 'spec_helper'

describe 'fdio' do

  shared_examples_for 'fdio - default' do
    it { should compile }
    it { should compile.with_all_deps }

    # Confirm presence of classes
    it { should contain_class('fdio') }
    it { should contain_class('fdio::params') }
    it { should contain_class('fdio::install') }
    it { should contain_class('fdio::config') }
    it { should contain_class('fdio::service') }

    # Confirm relationships between classes
    it { should contain_class('fdio::install').that_comes_before('Class[fdio::config]') }
    it { should contain_class('fdio::config').that_requires('Class[fdio::install]') }
    it { should contain_class('fdio::config').that_notifies('Class[fdio::service]') }
    it { should contain_class('fdio::service').that_subscribes_to('Class[fdio::config]') }
    it { should contain_class('fdio::service').that_comes_before('Class[fdio]') }
    it { should contain_class('fdio').that_requires('Class[fdio::service]') }
  end

  shared_examples_for 'fdio - rpm' do
    it {
      should contain_yumrepo('fdio-release').with(
        'baseurl' => 'https://nexus.fd.io/content/repositories/fd.io.centos7/',
        'enabled' => 1,
      )
    }
    it { should contain_package('vpp').that_requires('Yumrepo[fdio-release]') }

    context 'with stable 16.09 branch' do
      let(:params) {{:repo_branch => 'stable.1609'}}

      it {
        should contain_yumrepo('fdio-stable.1609').with(
          'baseurl' => 'https://nexus.fd.io/content/repositories/fd.io.stable.1609.centos7/',
          'enabled' => 1,
        )
      }
      it { should contain_package('vpp').that_requires('Yumrepo[fdio-stable.1609]') }
    end
  end

  shared_examples_for 'fdio - config' do
    it {
      should contain_vpp_config('dpdk/uio-driver').with_value('uio_pci_generic')
      should contain_vpp_config('dpdk/dev/default')
      should contain_vpp_config('cpu/main-core')
      should contain_vpp_config('cpu/corelist-workers')
    }
    it {
      should contain_exec('insert_dpdk_kmod').with(
        'command' => 'modprobe uio_pci_generic',
        'unless'  => 'lsmod | grep uio_pci_generic',
      )
    }
  end

  shared_examples_for 'fdio - service' do
    it {
      should contain_service('vpp').with(
        'ensure' => 'running',
        'enable'  => true,
      )
    }

  end

  context 'on RedHat platforms' do
    let(:facts) {{
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'CentOS',
        :operatingsystemmajrelease => '7',
    }}

    it_configures 'fdio - default'
    it_configures 'fdio - rpm'
    it_configures 'fdio - config'
    it_configures 'fdio - service'
  end
end