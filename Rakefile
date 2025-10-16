require 'simp/rake/beaker'
require 'bundler/gem_tasks'

Simp::Rake::Beaker.new(__dir__)

def syntax_check(task, glob)
  warn "---> #{task.name}"
  Dir.glob(glob).map do |file|
    puts '------| Attempting to load: ' + file
    yield(file)
  end
end

namespace :syntax do
  desc 'Syntax check for facts files under facts/'
  task :facts do |t|
    require 'json'
    syntax_check(t, 'facts/**/*.facts') { |j| JSON.parse(File.read(j)) }
  end
end

desc 'special notes about these rake commands'
task :help do
  puts %(
== environment variables ==
SIMP_RPM_BUILD     when set, alters the gem produced by pkg:gem to be RPM-safe.
                   'pkg:gem' sets this automatically.
  )
end

desc 'Run spec tests'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--color']
  t.exclude_pattern = '**/{acceptance,fixtures,files}/**/*_spec.rb'
  t.pattern = 'spec/**/*_spec.rb'
end

desc "run all RSpec tests (alias of 'spec')"
task test: :spec

desc 'Run acceptance tests'
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

namespace :pkg do
  @specfile_template = "rubygem-#{@package}.spec.template"
  @specfile          = "build/rubygem-#{@package}.spec"

  # ----------------------------------------
  # DO NOT UNCOMMENT THIS: the spec file requires a lot of tweaking
  # ----------------------------------------
  #  desc "generate RPM spec file for #{@package}"
  #  task :spec => [:clean, :gem] do
  #    Dir.glob("pkg/#{@package}*.gem") do |pkg|
  #      sh %Q{gem2rpm -t "#{@specfile_template}" "#{pkg}" > "#{@specfile}"}
  #    end
  #  end

  desc "build rubygem package for #{@package}"
  task gem: :chmod do
    Dir.chdir @rakefile_dir
    Dir['*.gemspec'].each do |spec_file|
      rpm_build = ENV.fetch('SIMP_RPM_BUILD', '1')
      cmd = %(SIMP_RPM_BUILD=#{rpm_build} bundle exec gem build "#{spec_file}")
      sh cmd
      FileUtils.mkdir_p 'dist'
      FileUtils.mv Dir.glob("#{@package}*.gem"), 'dist/'
    end
  end

  desc "build and install rubygem package for #{@package}"
  task install_gem: [:clean, :gem] do
    Dir.chdir @rakefile_dir
    Dir.glob("dist/#{@package}*.gem") do |pkg|
      sh %(bundle exec gem install #{pkg})
    end
  end

  desc "generate RPM for #{@package}"
  task :rpm, [:mock_root] => [:clean, :gem] do |_t, args|
    require 'tmpdir'
    mock_root = args[:mock_root]
    # TODO : Get rid of this terrible code.  Shoe-horned in until
    # we have a better idea for auto-decet
    if %r{^epel-6}.match?(mock_root) then el_version = '6'
    elsif %r{^epel-7}.match?(mock_root) then el_version = '7'
    else
      puts 'WARNING: Did not detect epel version'
    end

    if (tmp_dir = ENV.fetch('SIMP_MOCK_SIMPGEM_ASSETS_DIR', false))
      FileUtils.mkdir_p tmp_dir
    else
      tmp_dir = Dir.mktmpdir("build_#{@package}")
    end

    begin
      Dir.chdir tmp_dir
      specfile     = "#{@rakefile_dir}/build/rubygem-#{@package}.el#{el_version}.spec"
      tmp_specfile = "#{tmp_dir}/rubygem-#{@package}.el#{el_version}.spec"

      # We have to copy to a local directory because mock bugs out in NFS
      # home directories (where SIMP devs often work)
      FileUtils.cp specfile, tmp_specfile, preserve: true
      Dir.glob("#{@rakefile_dir}/dist/#{@package}*.gem") do |pkg|
        FileUtils.cp pkg, tmp_dir, preserve: true
      end

      # Build SRPM from specfile
      sh %(mock -r #{mock_root} --buildsrpm --source="#{tmp_dir}" --spec="#{tmp_specfile}" --resultdir="#{tmp_dir}")

      # Build RPM from SRPM
      Dir.glob("#{tmp_dir}/rubygem-#{@package}-*.el#{el_version}*.src.rpm") do |pkg|
        sh %(mock -r #{mock_root} --rebuild "#{pkg}" --resultdir=#{tmp_dir} --no-cleanup-after)
      end

      sh %(ls -l "#{tmp_dir}")

      # copy RPM back into pkg/
      Dir.glob("#{tmp_dir}/rubygem-#{@package}-*.el#{el_version}*.rpm") do |pkg|
        sh %(cp "#{pkg}" "#{@rakefile_dir}/dist/")
        FileUtils.cp pkg, "#{@rakefile_dir}/dist/"
      end
    ensure
      Dir.chdir @rakefile_dir
      # cleanup if needed
      unless ENV.fetch('SIMP_MOCK_SIMPGEM_ASSETS_DIR', false)
        FileUtils.remove_entry_secure tmp_dir
      end
    end
  end
end

# vim: syntax=ruby
