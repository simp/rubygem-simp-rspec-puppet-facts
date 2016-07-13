require 'puppet'
require 'json'
require 'facter'

ENV['FACTERLIB'].split(':').each{|x| Facter.search x }

Puppet.initialize_settings
Facter.loadfacts
jj JSON.parse Facter.collection.to_hash.to_json
