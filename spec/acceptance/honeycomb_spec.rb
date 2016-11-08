require 'spec_helper_acceptance'

describe 'fdio::honeycomb' do

  describe 'default parameters' do
    it 'should work with no errors' do
      pp= <<-EOS
      class { '::fdio::honeycomb': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('honeycomb') do
      it { should be_installed }
    end

    describe file('/opt/honeycomb/config/honeycomb.json') do
      it { is_expected.to exist }
      its(:content) { should match /"restconf-port":\s+8181/ }
      its(:content) { should match /"restconf-websocket-port":\s+7779/ }
      its(:content) { should match /"username":\s+"admin"/}
      its(:content) { should match /"password":\s+"admin"/}
    end

    describe service('honeycomb') do
      it { should be_running }
      it { should be_enabled }
    end
  end

end