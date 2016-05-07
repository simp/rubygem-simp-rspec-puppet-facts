require 'json'

module Simp; end
module Simp::RspecPuppetFacts
  require File.expand_path('version', File.dirname(__FILE__))

  def on_supported_os( opts = {} )
    h = Simp::RspecPuppetFacts::Shim.on_supported_os( opts )

    h.each do | os, facts |
      facter_version=Facter.version[0..2]
      facts_file = File.expand_path("../../facts/#{facter_version}/#{os}.facts", File.dirname(__FILE__))
      if File.file? facts_file
        newer_facts_raw = File.open(
          File.expand_path("../../facts/#{facter_version}/#{os}.facts", File.dirname(__FILE__))
        ).read
        newer_facts = symbolize_keys JSON.parse( newer_facts_raw )

        newer_facts.keep_if{ |k,v| (newer_facts.keys-facts.keys).include? k }

        facts.merge! lsb_facts( facts )
        facts.merge! selinux_facts
        facts.merge! newer_facts
        facts.merge! opts.fetch( :extra_facts, {} )
      end

      if ( ENV.key?('SIMP_FACTS_OS') &&
           !ENV['SIMP_FACTS_OS'].nil? &&
           ENV['SIMP_FACTS_OS'].strip != '' &&
           ENV['SIMP_FACTS_OS'] !~ /all/i )
        unless ENV['SIMP_FACTS_OS'].split(/[ ,]+/).include? os
          h.delete(os)
        end
      end
    end

    h
  end


  def lsb_facts( facts )
    lsb_facts = {}
    # attempt to massage a major release version if missing (for facter 1.6)
    unless ENV['SIMP_FACTS_lsb'] == 'no'
      puts "==== mocking lsb facts [disable with SIMP_FACTS_lsb=no]" if ENV['VERBOSE']
      rel = facts.fetch(:operatingsystemmajrelease,
                        facts.fetch(:operatingsystemrelease).split('.').first)
      lsb_facts[:lsbmajdistrelease] = rel
    end
    lsb_facts
  end

  def selinux_facts
    sefacts = {}
    unless ENV['SIMP_FACTS_selinux'] == 'no'
      puts "==== mocking selinux facts [disable with SIMP_FACTS_selinux=no]" if ENV['VERBOSE']
      puts "====   options: SIMP_FACTS_selinux=no|enforcing|permissive|disabled" if ENV['VERBOSE']
      sefacts_enforcing = {
        :selinux              => true,
        :selinux_current_mode => 'enforcing',
        :selinux_state        => 'enforcing',
      }
      sefacts_permissive = {
        :selinux              => true,
        :selinux_current_mode => 'permissive',
        :selinux_state        => 'permssive',
      }
      sefacts_disabled = {
        :selinux              => false,
        :selinux_current_mode => 'disabled',
        :selinux_state        => 'disabled',
      }
      sefacts = sefacts_enforcing
      sefacts = sefacts_enforcing  if ENV['SIMP_FACTS_selinux'] =~ /enforcing/i
      sefacts = sefacts_permissive if ENV['SIMP_FACTS_selinux'] =~ /permissive/i
      sefacts = sefacts_disabled   if ENV['SIMP_FACTS_selinux'] =~ /disabled/i
    end
    sefacts
  end

  def symbolize_keys(hash)
    hash.inject({}){|result, (key, value)|
      new_key = case key
                when String then key.to_sym
                else key
                end
      new_value = case value
                  when Hash then symbolize_keys(value)
                  else value
                  end
      result[new_key] = new_value
      result
    }
  end

  class Shim
    require 'rspec-puppet-facts'
    extend ::RspecPuppetFacts
  end
end
