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

       # attempt to massage a major release version if missing (for facter 1.6)
       rel = facts.fetch(:operatingsystemmajrelease,
                         facts.fetch(:operatingsystemrelease).split('.').first)
       facts[:lsbmajdistrelease] = rel
       extra_facts               = extra_os_facts.fetch( facts.fetch( :operatingsystem )).fetch( rel ).fetch( facts.fetch(:architecture) )
       extra_opts_facts          = opts.fetch( :extra_facts, {} )

       facts.merge! extra_facts
       facts.merge! extra_opts_facts

       facts
    end

    h
  end

  class Shim
    require 'rspec-puppet-facts'
    extend ::RspecPuppetFacts
  end
end
