require 'json'

module Simp; end
module Simp::RspecPuppetFacts
  require File.expand_path('version', File.dirname(__FILE__))

  SELINUX_MODES= [:enforcing, :disabled, :permissive]

  def on_supported_os( opts = {} )
    h = Simp::RspecPuppetFacts::Shim.on_supported_os( opts )
    selinux_mode = opts.fetch(:selinux_mode,:enforcing)

    h.each do | os, facts |
      facter_version=Facter.version[0..2]
      facts_file = File.expand_path("../../facts/#{facter_version}/#{os}.facts", File.dirname(__FILE__))
      if File.file? facts_file
        captured_facts_raw = File.open(
          File.expand_path("../../facts/#{facter_version}/#{os}.facts", File.dirname(__FILE__))
        ).read
        captured_facts = symbolize_keys JSON.parse( captured_facts_raw )
        captured_facts.keep_if{ |k,v| (captured_facts.keys-facts.keys).include? k }

        facts.merge! captured_facts
        facts.merge! opts.fetch( :extra_facts, {} )
        facts.merge! lsb_facts( facts )
        facts.merge! selinux_facts( selinux_mode, facts )
        facts.merge! opts.fetch( :extra_facts_immutable, {} )
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

  def selinux_facts( mode, facts )
    unless SELINUX_MODES.include?( mode )
      fail "FATAL: `mode` must be one of: #{SELINUX_MODES.map{|x| x.to_s.sub(/^/,':')}.join(', ')}"
    end
    sefacts = {}
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
    sefacts = sefacts_enforcing  if mode == :enforcing
    sefacts = sefacts_permissive if mode == :permissive
    sefacts = sefacts_disabled   if mode == :disabled

    # ensure mount options in :tmp_mount_* facts match
    ['tmp','var_tmp','dev_shm'].each do |m|
      k = "tmp_mount_#{m}".to_sym
      if mount_opts = facts.fetch(k,false)
        if mode == :disabled
          sefacts[k] = mount_opts.sub(/,seclabel$|seclabel,/, '')
        else
          unless mount_opts =~ /\bseclabel\b/
            sefacts[k] = "#{mount_opts},seclabel"
          end
        end
      end
    end
    facts.merge sefacts
  end

  # recursively onvert all hash keys to symbols
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
