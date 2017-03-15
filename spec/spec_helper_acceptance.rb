require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

hiera_config = YAML.load_file(File.expand_path(File.join(File.dirname(__FILE__), 'fixtures/hiera.yaml')))
write_hiera_config hiera_config[:hierarchy]
copy_hiera_data File.expand_path(File.join(File.dirname(__FILE__), 'fixtures/hieradata'))

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'cachet')
    hosts.each do |host|
      # Install git for cloning modules
      on host, 'yum install git -y'

      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
