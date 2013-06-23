require 'rubygems'
require 'bundler/setup'

require 'rake'
require 'rspec/core/rake_task'
require 'sdoc'
require 'rdoc/task'
require './lib/sprinkle/version'

task "inst" => [:clobber, :build] do
  puts `gem install pkg/sprinkle-*.gem`
end

desc 'Default: run specs.'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

desc "Generate code coverage"
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

class RDoc::Comment
  def gsub(*args)
    @text.gsub(*args)
  end
end

RDoc::Task.new do |rdoc|
  version = Sprinkle::Version
  
  rdoc.options << '-e' << 'UTF-8'
  rdoc.options << '-f' << 'sdoc'
  # rdoc.options << "-T" << "rails"
  
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "sprinkle #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

STATS_DIRECTORIES = [
  %w(Library            lib/sprinkle/),
  %w(Specs              spec),
].collect { |name, dir| [ name, "./#{dir}" ] }.select { |name, dir| File.directory?(dir) }
BROKEN = [
  %w(Actors             lib/sprinkle/actors),
  # %w(Errors             lib/sprinkle/errors),
  # %w(Extensions         lib/sprinkle/extensions),
  %w(Installers         lib/sprinkle/installers),
  # %w(Utility            lib/sprinkle/utility),
  %w(Package            lib/sprinkle/package),
  %w(Verifiers          lib/sprinkle/verifiers),
].collect { |name, dir| [ name, "./#{dir}" ] }.select { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'rails/code_statistics'
  CodeStatistics::TEST_TYPES << "Specs"
  cs=CodeStatistics.new(*BROKEN)
  cs.instance_variable_set("@total",nil)
  cs.to_s
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end
