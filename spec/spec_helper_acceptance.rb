require 'beaker-rspec'
require 'tmpdir'
require 'yaml'
require 'simp/beaker_helpers'
include Simp::BeakerHelpers

require 'beaker-windows'
include BeakerWindows::Path
include BeakerWindows::Powershell
include BeakerWindows::Registry
include BeakerWindows::WindowsFeature

unless ENV['BEAKER_provision'] == 'no'
  to_skip = []

  hosts.each do |host|
    # Install OpenVox
    if ENV['FACTER_GEM_VERSION']
      begin
        install_puppet_from_gem_on(
          host,
          version: ENV['PUPPET_VERSION'],
          facter_version: ENV['FACTER_GEM_VERSION'],
        )

        # Make scaffold dirs?
        code_dir = on(host, 'puppet config print codedir').stdout.strip

        host.mkdir_p("#{code_dir}/modules")
      rescue => e
        puts "#{host} does not support installing puppet from Gem...skipping"
        puts e

        to_skip << host

        next
      end
    else
      install_puppet
    end
  end

  to_skip.each do |host|
    hosts.delete(host)
  end
end

RSpec.configure do |c|
  # ensure that environment OS is ready on each host
  fix_errata_on(hosts)

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install modules and dependencies from spec/fixtures/modules
    copy_fixture_modules_to(hosts)
  rescue StandardError, ScriptError => e
    raise e unless ENV['PRY']
    require 'pry'
    binding.pry # rubocop:disable Lint/Debugger
  end
end
