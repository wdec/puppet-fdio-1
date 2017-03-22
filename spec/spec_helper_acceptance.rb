require 'beaker-rspec'

install_puppet_on(hosts, options)

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(Dir.getwd))
  module_name = JSON.parse(open('metadata.json').read)['name'].split('-')[1]

  # Make sure proj_root is the real project root
  unless File.exists?("#{proj_root}/metadata.json")
    raise "bundle exec rspec spec/acceptance needs be run from module root."
  end

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      # Start out with clean moduledir, don't trust r10k to purge it
      on host, "rm -rf /etc/puppet/modules/*"

      # Make sure EPEL is not installed.
      # It can happens in OpenStack Infra when using centos7 images.
      if os[:family].casecmp('RedHat') == 0
        on host, "rpm -e epel-release || true"
      end

      on(host, puppet('module', 'install', 'puppetlabs-stdlib'))
      on(host, puppet('module', 'install', 'puppetlabs-dummy_service'))

      # Install the module being tested
      on host, "rm -fr /etc/puppet/modules/#{module_name}"
      puppet_module_install(:source => proj_root, :module_name => module_name)

    end
  end
end