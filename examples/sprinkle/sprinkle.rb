#!/usr/bin/env sprinkle -s

# Example of a simple Sprinkle script to install a single gem on a remote host.

# Packages, sprinkle and its dependencies including rubygems and ruby, delivery mechanism
# uses Vlad

package :build_essential do
  description 'Build tools'
  apt 'build-essential'
end

package :ruby do
  description 'Ruby Virtual Machine'
  version '1.8.6'
  source "ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-#{version}-p111.tar.gz" # implicit :style => :gnu
  requires :ruby_dependencies
end

package :ruby_dependencies do
  description 'Ruby Virtual Machine Build Dependencies'
  apt %w( bison zlib1g-dev libssl-dev libreadline5-dev libncurses5-dev file )
end

package :rubygems do
  description 'Ruby Gems Package Management System'
  version '1.0.1'
  source "http://rubyforge.org/frs/download.php/29548/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb'
  end
  requires :ruby
end

package :sprinkle do
  description 'Sprinkle Provisioning Tool'
  gem 'sprinkle' do
    source 'http://gems.github.com' # use alternate gem server
  end
end


# Policy, sprinkle policy requires only the sprinkle gem

policy :sprinkle, :roles => :app do
  requires :sprinkle
end


# Deployment

deployment do

  # mechanism for deployment
  delivery :vlad do
    role :app, 'yourhost.com'
  end

end

# End of script, given the above information, Spinkle will apply the defined policy on all roles using the
# deployment settings specified.
