# Variables:
#
# SIMP_GEM_SERVERS   | a space/comma delimited list of rubygem servers
# PUPPET_VERSION     | specifies the version of the puppet gem to load
# FACTER_GEM_VERSION | specifies the version of the facter to load
puppetversion = ENV.fetch('PUPPET_VERSION', ['>= 7.0', '< 9.0'])
gem_sources   = ENV.key?('SIMP_GEM_SERVERS') ? ENV['SIMP_GEM_SERVERS'].split(/[, ]+/) : ['https://rubygems.org']

gem_sources.each { |gem_source| source gem_source }

gemspec

gem 'puppet', puppetversion, :require => false

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
end

group :test do
  gem 'beaker'
  gem 'beaker-rspec'
  gem 'beaker-windows'
  gem 'simp-beaker-helpers', ['>= 1.25.0', '< 2.0']
  gem 'puppetlabs_spec_helper', '~> 6.0'
  # For EL9
  gem 'net-ssh', '~> 7.0'
  gem 'bcrypt_pbkdf' unless RUBY_PLATFORM == 'java'
end
