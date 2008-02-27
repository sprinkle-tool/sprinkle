#$:.unshift(File.dirname(__FILE__) + '/../lib')
$: << File.expand_path(File.dirname(__FILE__) + '/../lib')


## REVISIT: idea i'm toying with is that you have separate files for platforms, that way deploy doesn't have to know about 
# platform specifics, but perhaps thats something we want... needs further thought

require 'rubygems'
require 'sprinkle'

## Special package, anything that defines a 'source' package means build-essential should be installed for Ubuntu

package :build_essential do
  description 'Build tools'
  apt 'build-essential'
end

## Defines available packages

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

package :mysql, :provides => :database do
  description 'MySQL Database'
  apt %w( mysql-server mysql-client )
end

package :apache, :provides => :webserver do
  description 'Apache 2 HTTP Server'
  version '2.2.6'
  source "http://apache.wildit.net.au/httpd/httpd-#{version}.tar.bz2" do
    enable %w( mods-shared=all proxy proxy-balancer proxy-http rewrite cache headers ssl deflate so )
    prefix "/opt/local/apache2-#{version}"
    post :install, 'install -m 755 support/apachectl /etc/init.d/apache2', 'update-rc.d -f apache2 defaults'
  end
  requires :apache_dependencies
end

package :apache_dependencies do
  description 'Apache 2 HTTP Server Build Dependencies'
  apt %w( openssl libtool mawk zlib1g-dev libssl-dev )
end

package :rubygems do
  description 'Ruby Gems Package Management System'
  version '1.0.1'
  source "http://rubyforge.org/frs/download.php/29548/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb'
  end
  requires :ruby
end

package :rails do
  description 'Ruby on Rails'
  gem 'rails'
  version '2.0.2'  
end

package :mongrel, :provides => :appserver do
  description 'Mongrel Application Server'
  gem 'mongrel'
  version '1.1.3'
end

package :mongrel_cluster do
  description 'Cluster Management for Mongrel'
  gem 'mongrel_cluster'
  version '1.0.5'
  requires :mongrel
end


## Define a policy that applies to what roles of machines

policy :rails, :roles => :app do
  requires :rails, :version => '2.0.2'
  requires :appserver
  requires :database
  requires :webserver
end

deployment do
  
  # better name
  delivery :capistrano
  
  # installer defaults
  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end
  
end

