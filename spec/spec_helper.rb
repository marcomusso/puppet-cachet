require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.hiera_config = File.join(PuppetlabsSpec::FIXTURE_DIR, 'hiera.yaml')
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
