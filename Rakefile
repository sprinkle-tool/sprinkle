require 'rake'
require 'spec/rake/spectask'

desc 'Run RSpec Suite'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end