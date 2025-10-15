require 'spec_helper'

describe 'Simp::RspecPuppetFacts' do
  facts_top_path = File.expand_path('../facts', File.dirname(__FILE__))
  facter_paths = Dir[File.join(facts_top_path, '?.?')].sort

  facter_paths.each do |facter_path|
    warn "=== facter_path = '#{facter_path}'"
    facter_version = File.basename(facter_path)
    describe "factsets for Facter #{facter_version}" do
      Dir[File.join(facter_path, '*.facts')].each do |facts_file|
        os = File.basename(facts_file).sub(%r{\.facts$}, '')
        context "for #{os}" do
          let(:facts) { YAML.load_file facts_file }

          it 'uses the fqdn "foo.example.com"' do
            expect(facts['networking']['fqdn']).to eq 'foo.example.com'
          end

          it 'uses the ipaddress "10.0.2.15"' do
            expect(facts['networking']['ip']).to eq '10.0.2.15'
          end

          it 'has a grub_version' do
            expect(facts['grub_version']).to match(%r{^(0\.9|2\.)})
          end
        end
      end
    end
  end
end
