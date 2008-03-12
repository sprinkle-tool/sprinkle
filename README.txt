Sprinkle
========

Sprinkle is a software provisioning tool you can use to build remote servers with, after the base operating 
system has been installed. For example, to install a Rails or Merb stack on a brand new slice directly after
its been created.

Properties of packages such as their name, type, dependencies, etc, and what packages apply to what machines 
is described via a domain specific language that Sprinkle executes (in fact one of the aims of Sprinkle is to 
define as concisely as possible a language for installing software).

An example package description follows:

    package :ruby do
      description 'Ruby Virtual Machine'
      version '1.8.6'
      source "ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-#{version}-p111.tar.gz" # implicit :style => :gnu
      requires :ruby_dependencies
    end

This defines a package called 'ruby', that uses the source based installer to build Ruby 1.8.6 from source, 
installing the package 'ruby_dependencies' beforehand.

Reasonable defaults are set by sprinkle, such as the install prefix, download area, etc, but can be customized
globally or per package (see below for an example).

Since packages come in many forms (eg. gems, pre-compiled debs, compressed source tar.gz, etc), Sprinkle supports
many different installer types, giving you the most amount of flexibility of how you'd like software installed.
New installer types can be added into the system easily.

For example, you could install Rails via gems, nginx via source, and mysql via APT.

Sprinkle also supports dependencies between packages, allowing you specify pre-requisites that need to be 
installed in order.

Packages can be grouped into polices to define several packages that should be installed together.

An example policy:

    policy :rails, :roles => :app do
      requires :rails, :version => '2.0.2'
      requires :appserver
      requires :database
      requires :webserver
    end

This defines a policy called Rails, that applies to machines of role :app. The policy includes the packages 
rails (version 2.0.2), appserver, database and webserver.

appserver, database and webserver can be virtual packages, where the user will be prompted for selection if
multiple choices for the virtual package exist.

Sprinkle is architected to be extendable in many ways, one of those areas is in its deployment of commands to
remote hosts. Currently Sprinkle uses Capistrano to issue commands on remote hosts via ssh, but it could also
conceivably use vlad, etc, or be used to simply issue installation commands on the local system.

An full example Sprinkle deployment script for deploying Rails (via gems), MySQL (via APT), and Apache (via source):

    require 'sprinkle'

    ## Special package, anything that defines a 'source' package will have an automatic dependency to build-essential under Ubuntu

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

    ## Deployment defaults

    deployment do
  
      # how commands are run on the remote systems
      delivery :capistrano
  
      # installer defaults
      source do
        prefix   '/usr/local'           # where all source packages will be configured to install
        archives '/usr/local/sources'   # where all source packages will be downloaded to
        builds   '/usr/local/build'     # where all source packages will be built
      end
  
    end

Sprinkle is a work in progress and I'm excited to hear if anyone finds it useful - please feel free to 
comment, ask any questions, or send in any ideas, patches, bugs. All most welcome.

Marcus Crafter <crafterm@redartisan.com>

