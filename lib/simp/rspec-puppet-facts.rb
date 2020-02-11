module Simp; end
module Simp::RspecPuppetFacts
  require 'json'
  require 'puppet'

  require File.expand_path('version', File.dirname(__FILE__))

  SELINUX_MODES = [:enforcing, :disabled, :permissive]

  def supported_os_strings( opts )
    supported_os = opts.fetch(:supported_os, RspecPuppetFacts.meta_supported_os)
    hardwaremodels = opts.fetch(:hardwaremodels, ['x86_64'])
    os_strings = []
    supported_os.each do |os|
      os['operatingsystemrelease'].each do |rel|
        hardwaremodels.each do |hw|
          os_strings << [os['operatingsystem'],rel,hw].map{|x| x.downcase.gsub(/\s/,'_') }.join('-')
        end
      end
    end
    os_strings
  end

  # Don't ask rspec-puppet-facts for operatingsystems we've already recorded
  # because if it doesn't have them it will crash
  def filter_opts( opts, simp_h, filter_type = :reject )
    rfh_hw = opts.fetch(:hardwaremodels, ['x86_64'])
    rfh_os = opts.fetch(:supported_os, RspecPuppetFacts.meta_supported_os).dup
    _os = rfh_os.send(filter_type) do |os|
      _name = os['operatingsystem']
      _rels = os['operatingsystemrelease'].send(filter_type) do |rel|
        _hw = rfh_hw.send(filter_type) do |hw|
          simp_h.key? [_name,rel,hw].map{|x| x.downcase.gsub(/\s/,'_') }.join('-')
        end
        !_hw.empty?
      end
      !_rels.empty?
    end
    _opts = opts.dup
    _opts[:supported_os] = _os
    _opts
  end

  def on_supported_os( opts = {} )
    opts[:selinux_mode]       ||= :enforcing
    opts[:simp_fact_dir_path] ||= File.expand_path("../../facts/",
                                                   File.dirname(__FILE__))

    simp_h         = load_facts(opts[:simp_fact_dir_path])
    strings        = supported_os_strings(opts)
    masked_opts    = filter_opts(opts, simp_h, :reject)
    selected_opts  = filter_opts(opts, simp_h, :select)
    rfh_h  = Simp::RspecPuppetFacts::Shim.on_supported_os(masked_opts)

    h = rfh_h.merge(simp_h).select{|k,v| supported_os_strings(opts).include? k}

    h.each do | os, facts |
      facter_ver=Facter.version.split('.')[0..1].join('.')
      facts_file = File.expand_path("../../facts/#{facter_ver}/#{os}.facts",
                                    File.dirname(__FILE__))
      if File.file? facts_file
        captured_facts_raw = File.open(
          File.expand_path("../../facts/#{facter_ver}/#{os}.facts",
                           File.dirname(__FILE__))
        ).read
        captured_facts = symbolize_keys JSON.parse( captured_facts_raw )
        captured_facts.keep_if{ |k,v| (captured_facts.keys-facts.keys).include? k }

        facts.merge! captured_facts
        facts.merge! opts.fetch( :extra_facts, {} )
        facts.merge!({ :puppetversion => ::Puppet.version })
        facts.merge! lsb_facts( facts )
        facts.merge! selinux_facts( opts[:selinux_mode], facts )
        facts.merge! opts.fetch( :extra_facts_immutable, {} )
      end

      if ( ENV.fetch('SIMP_FACTS_OS',nil) &&
           !ENV['SIMP_FACTS_OS'].strip.empty? &&
           ENV['SIMP_FACTS_OS'] !~ /all/i )
        unless ENV['SIMP_FACTS_OS'].strip.split(/[ ,]+/).include? os
          h.delete(os)
        end
      end
    end

    h
  end


  def lsb_facts( facts )
    return facts if facts[:kernel].casecmp('windows')

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
      :selinux_enforced     => true,
      :selinux_current_mode => 'enforcing',
      :selinux_state        => 'enforcing',
    }
    sefacts_permissive = {
      :selinux              => true,
      :selinux_enforced     => false,
      :selinux_current_mode => 'permissive',
      :selinux_state        => 'permssive',
    }
    sefacts_disabled = {
      :selinux              => false,
      :selinux_enforced     => false,
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


  def load_facts( fact_dir_path )
    facter_xy_version = Facter.version.split('.')[0..1].join('.')
    fact_dir          = File.join(fact_dir_path,facter_xy_version)

    unless File.exists? fact_dir
      _msg = "Can't find SIMP facts for Facter #{facter_xy_version}, skipping...

HINT: If this version of Facter has been released recently, try running

    `FACTER_GEM_VERSION='~> X.Y.0' bundler update facter

Where 'X.Y' is the version of the last facter that worked"
      fail(_msg)
    end

    simp_h     = {}
    fact_files = Dir.glob( File.join(fact_dir, '*.facts') ).sort
    fact_files.each do |file|
      key  = File.basename(file).sub(/\.facts$/,'')
      data = JSON.parse(File.read(file))
      simp_h[key] = symbolize_keys(data)
    end
    simp_h
  end

  class Shim
    require 'rspec-puppet-facts'
    extend ::RspecPuppetFacts
  end
end
