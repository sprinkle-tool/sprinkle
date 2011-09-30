require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sprinkle"
    gem.summary = "Ruby DSL based software provisioning tool"
    gem.description = "Ruby DSL based software provisioning tool"
    gem.email = "crafterm@redartisan.com"
    gem.rubyforge_project = 'sprinkle'
    gem.homepage = "http://github.com/crafterm/sprinkle"
    gem.authors = ["Marcus Crafter"]
    gem.add_development_dependency("rspec", ">= 2.5")
    gem.add_dependency('activesupport', '>= 2.0.2')
    gem.add_dependency('highline', '>= 1.4.0')
    gem.add_dependency('capistrano', '>= 2.5.5')

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

task "inst" => [:clobber, :build] do
  puts `gem install pkg/sprinkle-*.gem`
end

task :spec => :check_dependencies

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


require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "sprinkle #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
