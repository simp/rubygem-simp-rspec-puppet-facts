require 'yaml'
require 'json'

# A cowardly Heap merge that only overwrites keys that already exist
def creep_merge(j, o)
  result = nil
  if o.is_a? Hash
    o.each_key do |k|
      puts "== k: #{k} | #{k.class} | j: #{j.class}" if ENV['VERBOSE'] == 'yes'
      if j.is_a?(Hash)
        if j.key?(k)
          j[k] = creep_merge(j[k], o[k])
        else
          warn "!!!!!!!!!  WARNING NO key '#{k}'"
          if ENV['PRY'] == 'yes'
            require 'pry'
            binding.pry # rubocop:disable Lint/Debugger
          end
        end
      else
        j = o[k]
      end
      result = j
    end
  else
    result = o
  end
  result
end

def scrub_data(f)
  scrub_ff = File.basename(f).sub('.facts', '.scrub.yaml')
  ff = File.expand_path("gce_scrub_data/#{scrub_ff}", File.dirname(__FILE__))
  scrub = YAML.load_file ff
  data = JSON.parse(File.read(f))
  ff = "#{f}.yaml"
  File.open(ff, 'w') { |fd| fd.puts data.to_yaml }
  fb = f.sub(%r{.facts$}, '.facts.bak')
  unless File.exist? fb
    File.open(fb, 'w') { |fd| fd.puts data }
    warn "== wrote '#{fb}'"
  end
  warn "== wrote '#{ff}'"
  scrubbed_data = creep_merge(data, scrub)
  scrubbed_data.fetch('gce', {}).fetch('project', {}).fetch('attributes', {}).fetch('sshKeys', []).delete_if { |x| x.include?('chris_tessmer') }
  File.open(f, 'w') { |fd| fd.puts JSON.pretty_generate(scrubbed_data) }
  warn "== wrote '#{f}'"
end

ARGV.each do |file|
  scrub_data(file)
end
