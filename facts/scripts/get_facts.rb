require 'puppet'
require 'json'
require 'facter'

ENV['FACTERLIB'].split(':').each{|x| Facter.search x }

Puppet.initialize_settings
jj JSON.parse Facter.collection.to_h.to_json
