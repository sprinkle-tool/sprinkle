# Sprinkle Rails deployment script
#
# This is an example Sprinkle script, configured to install Rails from gems, Apache and Ruby from source,
# and mysql from apt on an Ubuntu system. Installation is configured to run via capistrano (and
# an accompanying deploy.rb recipe script). Source based packages are downloaded and built into
# /usr/local on the remote system.
#
# A sprinkle script is separated into 3 different sections. Packages, policies and deployment.
#
# Packages
#
#  Defines the world of packages as we know it. Each package has a name and
#  set of metadata including its installer type (eg. apt, source, gem, etc). Packages can have
#  relationships to each other via dependencies
#
# Policies
#
#  Names a group of packages (optionally with versions) that apply to a particular set of roles.
#
# Deployment
#
#  Defines script wide settings such as a delivery mechanism for executing commands on the target
#  system (eg. capistrano), and installer defaults (eg. build locations, etc).


# Packages

package :build_essential do # special package, anything that uses a 'source' installer will have build-essential installed for Ubuntu
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

package :mongrel do
  description 'Mongrel Application Server'
  gem 'mongrel'
  version '1.1.4'
end

package :mongrel_cluster, :provides => :appserver do
  description 'Cluster Management for Mongrel'
  gem 'mongrel_cluster'
  version '1.0.5'
  requires :mongrel
end


# Policies

# Associates the rails policy to the application servers. Contains rails, and surrounding
# packages. Note, appserver, database and webserver are all virtual packages defined above. If
# there's only one implementation of a virtual package, it's selected automatically, otherwise
# the user is requested to select which one to use.

policy :rails, :roles => :app do
  requires :rails, :version => '2.0.2'
  requires :appserver
  requires :database
  requires :webserver
end

# Deployment

# Configures spinkle to use capistrano for delivery of commands to the remote machines (via
# the named 'deploy' recipe). Also configures 'source' installer defaults to put package gear
# in /usr/local

deployment do

  # mechanism for deployment
  delivery :capistrano do
    recipes 'deploy'
  end

  # source based package installer defaults
  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end

end
