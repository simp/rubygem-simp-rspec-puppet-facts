require 'spec_helper'
require 'English'
require 'timeout'

# Regression tests for https://github.com/simp/rubygem-simp-rspec-puppet-facts/issues/86
#
# If a spec_helper does a top-level `include RspecPuppetFacts` before this gem
# is loaded (voxpupuli-test does this), a plain `extend ::RspecPuppetFacts` on
# the Shim is silently skipped because the module is already in Object's
# ancestry.  A later top-level `include Simp::RspecPuppetFacts` then shadows
# the upstream method, and `Shim.on_supported_os` recurses without bound,
# consuming all available memory during fact loading.
describe 'Simp::RspecPuppetFacts::Shim' do
  describe '.on_supported_os' do
    it 'dispatches to the upstream rspec-puppet-facts implementation' do
      expect(Simp::RspecPuppetFacts::Shim.method(:on_supported_os).owner)
        .not_to eq Simp::RspecPuppetFacts
    end

    context 'when RspecPuppetFacts was included at the top level before this gem was loaded' do
      it 'terminates instead of recursing' do
        # An OS release with no SIMP factset (Debian here) forces
        # on_supported_os down the Shim path that used to recurse
        script = <<~SCRIPT
          require 'rspec'
          require 'rspec-puppet-facts'
          include RspecPuppetFacts
          require 'simp/rspec-puppet-facts'
          include Simp::RspecPuppetFacts
          facts = on_supported_os(
            supported_os: [
              { 'operatingsystem' => 'RedHat', 'operatingsystemrelease' => ['9'] },
              { 'operatingsystem' => 'Debian', 'operatingsystemrelease' => ['12'] },
            ],
          )
          exit!(1) unless facts.key?('redhat-9-x86_64')
          puts 'SHIM_DISPATCH_OK'
        SCRIPT

        lib_dir = File.expand_path('../../lib', __dir__)
        output = nil
        Timeout.timeout(120) do
          output = IO.popen([RbConfig.ruby, '-I', lib_dir, '-e', script], err: [:child, :out], &:read)
        end
        expect($CHILD_STATUS).to be_success, "subprocess failed (#{$CHILD_STATUS}):\n#{output}"
        expect(output).to include('SHIM_DISPATCH_OK')
      end
    end
  end
end
