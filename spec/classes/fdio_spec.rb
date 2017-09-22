require 'spec_helper'

describe 'fdio' do

    let :params do
      {}
    end

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
      it { should contain_package('vpp-plugins').that_requires('Package[vpp]') }
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

    context 'with socket_mem' do
      before :each do
        params.merge!(:vpp_dpdk_socket_mem => '1024,1024')
      end
      it 'should configure socket_mem' do
        is_expected.to contain_vpp_config('dpdk/socket-mem').with_value('1024,1024')
      end
    end

    context 'with vhost-user' do
      before :each do
        params.merge!(
          :vpp_vhostuser_coalesce_frames => 32,
          :vpp_vhostuser_coalesce_time => 0.05,
          :vpp_vhostuser_dont_dump_memory => true
        )
      end
      it 'should configure vhost-user options' do
        is_expected.to contain_vpp_config('vhost-user/coalesce-frames').with_value('32')
        is_expected.to contain_vpp_config('vhost-user/coalesce-time').with_value('0.05')
        is_expected.to contain_vpp_config('vhost-user/dont-dump-memory').with_ensure('present')
      end
    end

    context 'with tuntap/tapcli' do
      before :each do
        params.merge!(
          :vpp_tuntap_enable => true,
          :vpp_tuntap_mtu => 9000,
          :vpp_tapcli_mtu => 9000
        )
      end
      it 'should configure vhost-user options' do
        is_expected.to contain_vpp_config('tuntap/enable').with_ensure('present')
        is_expected.to contain_vpp_config('tuntap/mtu').with_value('9000')
        is_expected.to contain_vpp_config('tapcli/mtu').with_value('9000')
      end
    end

    context 'with exec commands' do
      before :each do
        params.merge!(
          :vpp_exec_commands => ['test line 1', 'test line 2'],
          :vpp_exec_file => '/etc/vpp/test_exec_file'
        )
      end
      it 'should configure exec lines' do
        is_expected.to contain_file('/etc/vpp/test_exec_file').with_ensure('present')
        is_expected.to contain_vpp_config('unix/exec').with_value('/etc/vpp/test_exec_file')
        is_expected.to contain_fdio__config__vpp_exec_line('test line 1')
        is_expected.to contain_fdio__config__vpp_exec_line('test line 2')
      end
    end
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