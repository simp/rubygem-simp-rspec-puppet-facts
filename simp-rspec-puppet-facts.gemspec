# -*- encoding: utf-8 -*-
require  File.expand_path('lib/simp/version.rb', File.dirname(__FILE__))
require 'date'

Gem::Specification.new do |s|
  s.name        = 'simp-rspec-puppet-facts'
  s.date        = Date.today.to_s
  s.summary     = 'standard SIMP facts fixtures for Puppet'
  s.version     = Simp::RspecPuppetFacts::VERSION
  s.email       = 'simp@simp-project.org'
  s.homepage    = 'https://github.com/simp/rubygem-simp-rspec-puppet-facts'
  s.description = 'shim that injects SIMP-related facts into rspec-puppet-facts'
  s.license     = 'Apache-2.0'
  s.authors     = [ 'Chris Tessmer', 'Mickaël Canévet']
  s.files       = Dir['Rakefile', '{bin,lib,facts,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z .`.split("\0")
  s.test_files  = Dir['Rakefile', '{spec,test,facts}/**/*'] & `git ls-files -z .`.split("\0")

  s.add_runtime_dependency     'rspec-puppet-facts', '~> 0'
  s.add_development_dependency 'puppetlabs_spec_helper', '~> 0'
  s.add_development_dependency 'rake',               '~> 10'
  s.add_development_dependency 'rspec',              '~> 3.2'

  s.add_runtime_dependency     'json',               '~> 1'
  s.add_runtime_dependency     'facter',             '>= 1.5.0', '< 3.0'

  s.add_development_dependency 'pry',                '~> 0'
  s.add_development_dependency 'tins',               '< 1.7' # 1.7+ breaks ruby 1.9

  s.requirements << 'rspec-puppet-facts'
end
