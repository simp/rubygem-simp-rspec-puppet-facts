module Simp; end
module Simp::RspecPuppetFacts
  require File.expand_path('version', File.dirname(__FILE__))

  # TODO: roll this into files
  def extra_os_facts
    {
      'CentOS' => {
         '6' => {
         'x86_64' => {
            :grub_version              => '0.97',
            :uid_min                   => '500',
          },
         },
         '7' => {
         'x86_64' => {
            :grub_version              => '2.02~beta2',
            :uid_min                   => '500',
          },
         },
      },
      'RedHat' => {
         '6' => {
         'x86_64' => {
            :grub_version              => '0.97',
            :uid_min                   => '500',
          },
         },
         '7' => {
         'x86_64' => {
            :grub_version              => '2.02~beta2',
            :uid_min                   => '500',

          },
         },
      },
    }
  end



  def on_supported_os( opts = {} )
    h = Simp::RspecPuppetFacts::Shim.on_supported_os( opts )

    h.each do | os, facts |
      facts.merge! lsb_facts( facts )
      facts.merge! selinux_facts
      facts.merge! extra_facts(facts)
      facts.merge! opts.fetch( :extra_facts, {} )

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



  def extra_facts( facts )
      _rel  = facts.fetch(:operatingsystemmajrelease).split('.').first
      _os   = facts.fetch( :operatingsystem )
      _arch = facts.fetch(:architecture)
      _extra_facts  = extra_os_facts.fetch(_os).fetch(_rel).fetch(_arch)
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
        :selinux_current_mode => :enforcing,
        :selinux_state        => :enforcing,
      }
      sefacts_permissive = {
        :selinux              => true,
        :selinux_current_mode => :permissive,
        :selinux_state        => :permssive,
      }
      sefacts_disabled = {
        :selinux              => false,
        :selinux_current_mode => :disabled,
        :selinux_state        => :disabled,
      }
      sefacts = sefacts_enforcing
      sefacts = sefacts_enforcing  if ENV['SIMP_FACTS_selinux'] =~ /enforcing/i
      sefacts = sefacts_permissive if ENV['SIMP_FACTS_selinux'] =~ /permissive/i
      sefacts = sefacts_disabled   if ENV['SIMP_FACTS_selinux'] =~ /disabled/i
    end
    sefacts
  end


  class Shim
    require 'rspec-puppet-facts'
    extend ::RspecPuppetFacts
  end
end
