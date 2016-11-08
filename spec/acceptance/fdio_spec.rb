require 'spec_helper_acceptance'

describe 'fdio' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      class { '::fdio': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('vpp') do
      it { should be_installed }
    end

    describe file('/etc/vpp/startup.conf') do
      it { is_expected.to exist }
      its(:content) { should match /uio-driver\s+uio_pci_generic/ }
      its(:content) { should_not match /dev/ }
    end

    describe service('vpp') do
      it { should be_running }
      it { should be_enabled }
    end
  end

  context 'pinning' do
    it 'should work with no errors' do
      pp= <<-EOS
      class { '::fdio':
        vpp_cpu_main_core => '1',
        vpp_cpu_corelist_workers => '2',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/etc/vpp/startup.conf') do
      its(:content) { should match /main-core\s+1/ }
      its(:content) { should match /corelist-workers\s+2/ }
    end

  end
end
