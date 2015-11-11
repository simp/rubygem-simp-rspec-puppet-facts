require 'coveralls'
Coveralls.wear!

require 'rspec'
#require 'mocha/api'
require 'simp/rspec-puppet-facts'
include Simp::RspecPuppetFacts

RSpec.configure do |config|
     config.mock_framework = :mocha
end
