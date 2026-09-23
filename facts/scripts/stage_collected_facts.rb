#!/usr/bin/env ruby
# frozen_string_literal: true

# Validate and stage factsets written by the default acceptance suite.
#
# Usage: stage_collected_facts.rb EXPECTED_AGENT_VERSION SOURCE_DIR DEST_DIR
#
# Every SOURCE_DIR/*.facts file must have been collected with openvox-agent
# EXPECTED_AGENT_VERSION (package version, e.g. '9.0.0~rc1'), so a factset is
# never filed under the wrong OpenFact version (simp/rubygem-simp-rspec-puppet-facts#71).
# Values that change on every collection are pinned so recollecting only
# produces diffs for facts that really changed. Each file is written to
# DEST_DIR/<openfact major.minor>/<name>.facts.

require 'fileutils'
require 'json'

# Normalize a package version ('9.0.0~rc1', '9.0.0-rc1') for comparison
def normalize_version(version)
  version.to_s.strip.tr('~', '-').sub(%r{-1(\.el\d+)?\z}, '')
end

UPTIME = {
  'uptime' => '0:10 hours',
  'uptime_seconds' => 600,
  'uptime_hours' => 0,
  'uptime_days' => 0,
}.freeze

def pin_volatile_facts(facts)
  UPTIME.each { |k, v| facts[k] = v if facts.key?(k) }
  if facts['system_uptime'].is_a?(Hash)
    facts['system_uptime'] = { 'days' => 0, 'hours' => 0, 'seconds' => 600, 'uptime' => '0:10 hours' }
  end
  facts['load_averages'] = { '15m' => 0.0, '1m' => 0.0, '5m' => 0.0 } if facts.key?('load_averages')
  facts
end

expected, source_dir, dest_dir = ARGV
abort("Usage: #{File.basename($PROGRAM_NAME)} EXPECTED_AGENT_VERSION SOURCE_DIR DEST_DIR") unless expected && source_dir && dest_dir

files = Dir.glob(File.join(source_dir, '*.facts')).sort
abort("No .facts files found in #{source_dir}") if files.empty?

errors = []
files.each do |file|
  facts = JSON.parse(File.read(file))
  # aio_agent_version drops pre-release tags ('9.0.0' for 9.0.0~rc1), so compare
  # against the OpenVox version, which keeps them ('9.0.0-rc1')
  agent = facts['puppetversion']
  facter = facts['facterversion']

  if normalize_version(agent) != normalize_version(expected)
    errors << "#{File.basename(file)}: collected with OpenVox #{agent.inspect}, expected #{expected.inspect}"
    next
  end

  facter_xy = facter.to_s.split('.').first(2).join('.')
  unless %r{\A\d+\.\d+\z}.match?(facter_xy)
    errors << "#{File.basename(file)}: unusable facterversion #{facter.inspect}"
    next
  end

  target = File.join(dest_dir, facter_xy, File.basename(file))
  FileUtils.mkdir_p(File.dirname(target))
  File.write(target, "#{JSON.pretty_generate(pin_volatile_facts(facts))}\n")
  puts "#{File.basename(file)}: OpenVox #{agent}, OpenFact #{facter} -> #{target}"
end

abort(errors.join("\n")) unless errors.empty?
