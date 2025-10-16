# Variables:
#
# SIMP_GEM_SERVERS   | a space/comma delimited list of rubygem servers
# OPENVOX_VERSION    | specifies the version of the openvox gem to load
# PUPPET_VERSION     | provided for backwards-compatibility
# OPENFACT_VERSION   | specifies the version of the openfact gem to load
# FACTER_GEM_VERSION | provided for backwards-compatibility
openvoxversion = ENV.fetch('OPENVOX_VERSION', ENV.fetch('PUPPET_VERSION', '~> 8.0'))
gem_sources = ENV.key?('SIMP_GEM_SERVERS') ? ENV['SIMP_GEM_SERVERS'].split(%r{[, ]+}) : ['https://rubygems.org']

gem_sources.each { |gem_source| source gem_source }

gemspec

gem 'openvox', openvoxversion, require: false

if (openfactversion = ENV.fetch('OPENFACT_VERSION', ENV.fetch('FACTER_GEM_VERSION', nil)))
  gem 'openfact', openfactversion, require: false
end

group :test do
  gem 'beaker', '~> 7.1.0'
  gem 'beaker_puppet_helpers', '~> 3.1.1'
  gem 'beaker-rspec', '~> 9.0.0'
  gem 'beaker-windows', '~> 0.6.2'
  gem 'puppetlabs_spec_helper', '~> 8.0.0'
  gem 'simp-beaker-helpers', '~> 2.0.4'
  # For EL9
  gem 'bcrypt_pbkdf', '~> 1.1.1' unless RUBY_PLATFORM == 'java'
  gem 'net-ssh', '~> 7.3.0'
  gem 'syslog', '~> 0.3.0'
end

group :syntax do
  gem 'rubocop', '~> 1.81.0'
  gem 'rubocop-performance', '~> 1.26.0'
  gem 'rubocop-rake', '~> 0.7.0'
  gem 'rubocop-rspec', '~> 3.7.0'
end

# Evaluate extra gemfiles if they exist
extra_gemfiles = [
  ENV.fetch('EXTRA_GEMFILE', ''),
  "#{__FILE__}.project",
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding) # rubocop:disable Security/Eval
  end
end
