package :ruby_dependencies do
  description 'Ruby Virtual Machine Build Dependencies'
  
  apt %w( bison zlib1g-dev libssl-dev libreadline5-dev libncurses5-dev file )
end

package :ruby do
  description 'Ruby Virtual Machine'
  version '1.8.6'
  patchlevel = '369'
  requires :ruby_dependencies
  
  source "ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-#{version}-p#{patchlevel}.tar.gz" # implicit :style => :gnu
end

package :rubygems do
  description 'Ruby Gems Package Management System'
  version '1.8.23'
  requires :ruby
  
  source "http://rubyforge.org/frs/download.php/60718/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb'
  end
end

package :rails do
  description 'Ruby on Rails'
  version '3.2'
  
  gem 'rails'
end
