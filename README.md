# Sprinkle [![Build Status](https://travis-ci.org/sprinkle-tool/sprinkle.png?branch=master)](https://travis-ci.org/sprinkle-tool/sprinkle) [![Code Climate](https://codeclimate.com/github/sprinkle-tool/sprinkle.png)](https://codeclimate.com/github/sprinkle-tool/sprinkle/)

Sprinkle is a software provisioning tool you can use to build remote servers with, after the base operating
system has been installed. For example, to install a Rails or Merb stack on a brand new slice directly after
its been created.

Sprinkle is a work in progress and I'm excited to hear if anyone finds it useful - please feel free to
comment, ask any questions, or send in any ideas, patches, bugs. All most welcome.

Marcus Crafter - <crafterm@redartisan.com>

## Packages

Properties of packages such as their name, type, dependencies, etc, and what packages apply to what machines
is described via a domain specific language that Sprinkle executes (in fact one of the aims of Sprinkle is to
define as concisely as possible a language for installing software).

An example:

``` ruby
package :ruby do
  description 'Ruby Virtual Machine'
  version '1.8.6'
  source "ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-#{version}-p111.tar.gz"
  requires :ruby_dependencies

  verify do
    has_file '/usr/bin/ruby'
  end
end
```

This defines a package called `ruby`, that uses the source based installer to build Ruby 1.8.6 from source,
installing the package `ruby_dependencies` beforehand. The package verifies it was installed correctly by verifying
the file `/usr/bin/ruby` exists after installation. If this verification fails, the sprinkle script will gracefully stop.

Reasonable defaults are set by sprinkle, such as the install prefix, download area, etc, but can be customized
globally or per package (see below for an example).

Since packages come in many forms (eg. gems, pre-compiled debs, compressed source tar.gz, etc), Sprinkle supports
many different installer types, giving you the most amount of flexibility of how you'd like software installed.
New installer types can be added into the system easily.

For example, you could install Rails via gems, nginx via source, and mysql via APT, while retaining the flexibility
of changing installer types as software is updated upstream.

Sprinkle also supports dependencies between packages, allowing you specify pre-requisites that need to be
installed in order.

**Note** When running commands that require `sudo`, you must use an installer which supports the `:sudo => true` option
and your deployment strategy must be capable of receiving input from your console.

### Installers

There are many installers available for packages see [`lib/sprinkle/installers`](lib/sprinkle/installers) for a full list.
However a few that you will find useful include `runner`, to run arbitrary commands, `source` to install packages from source
and there are installers for most package management systems e.g. Rubygems (`gem :rails`), aptitude (`apt :mysql`)

### Hooks

Sometimes you need to run commands before or after various points in a packages installation process, `pre` and `post`
hooks enable you to configure this behaviour. Hooks either take a simple shell command e.g.:

```Ruby
  pre :install, "mkdir /path/to/file"
```

Or a block in which you can run various installer commands.

```Ruby
  pre :install do
    runner "apt-get update", :sudo => true
  end
```

### Verifiers

Verifiers are used to check if an installation was successful (or has already been applied), installers will often provide
custom verify commands to aid this process. e.g:

```Ruby
package :user_setup, :provides => :deployment_user do
  description "Meta package to setup users"

  add_user "deploy", :flags => "--ingroup sudo"

  verify do
    has_user "deploy", :in_group => "sudo"
  end
end
```

## Policies

Packages can be grouped into polices to define several packages that should be installed together.  An example:

``` ruby
policy :rails, :roles => :app do
  requires :rails, :version => "3.2"
  requires :appserver
  requires :database
  requires :webserver
end
```

This defines a policy called Rails, that applies to machines of role `:app`. The policy includes the packages
rails (version 3.2), appserver, database and webserver.

The appserver, database and webserver packages can also be virtual, prompting the user for selection if multiple choices for the virtual package exist.

## Deployment

Sprinkle is architected to be extendable in many ways, one of those areas is in its deployment of commands to
remote hosts. Currently Sprinkle supports the use of Capistrano, Vlad, or a direct net/ssh connection to
issue commands on remote hosts via ssh, but could also be extended to use any other command transport mechanism
desired. Sprinkle can also be configured to simply issue installation commands to provision the local system.

**Note** When using Capistrano and `sudo`, it is likely you will need the `default_run_options[:pty] = true` option
set in order to authorise `sudo` attempts.

## Additional Resources

  * `#sprinkle` channel on the Freenode IRC Network
  * <http://redartisan.com/2008/5/27/sprinkle-intro>
  * <http://github.com/sprinkle-tool/sprinkle>
  * <http://github.com/benschwarz/passenger-stack>
  * <http://github.com/trevorturk/sprinkle-packages>
  * <http://www.vimeo.com/2888665>
  * <http://maxim.github.com/sprinkle-cheatsheet>
  * <http://github.com/mingalar/sprinkle-packages>
  * <http://github.com/stuartellis/spritz>
  * <http://engineering.gomiso.com/2011/08/26/forget-chef-or-puppet-automate-with-sprinkle/>

----

## APPENDIX

### A full example deployment

A full example Sprinkle deployment script for deploying Rails (via gems), MySQL (via APT), Apache (via source)
and Git (via source with dependencies from APT):

``` ruby
# Sprinkle Rails deployment script
#
# This is an example Sprinkle script, configured to install Rails from gems, Apache, Ruby and Git from source,
# and mysql and Git dependencies from apt on an Ubuntu system. Installation is configured to run via
# Capistrano (and an accompanying deploy.rb recipe script). Source based packages are downloaded and built into
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

package :ruby do
  description 'Ruby Virtual Machine'
  version '1.8.6'
  source "ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-#{version}-p111.tar.gz"
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
  version '2.2.9'
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
  version '1.2.0'
  source "http://rubyforge.org/frs/download.php/38646/rubygems-#{version}.tgz" do
    custom_install 'ruby setup.rb'
  end
  requires :ruby
end

package :rails do
  description 'Ruby on Rails'
  gem 'rails'
  version '3.2'
end

package :mongrel do
  description 'Mongrel Application Server'
  gem 'mongrel'
  version '1.1.5'
end

package :mongrel_cluster, :provides => :appserver do
  description 'Cluster Management for Mongrel'
  gem 'mongrel_cluster' # :source => 'http://gems.github.com/' for alternate gem server
  version '1.0.5'
  requires :mongrel
end

package :git, :provides => :scm do
  description 'Git Distributed Version Control'
  version '1.5.6.3'
  source "http://kernel.org/pub/software/scm/git/git-#{version}.tar.gz"
  requires :git_dependencies
end

package :git_dependencies do
  description 'Git Build Dependencies'
  apt 'git', :dependencies_only => true
end

# Policies

# Associates the rails policy to the application servers. Contains rails, and surrounding
# packages. Note, appserver, database and webserver are all virtual packages defined above. If
# there's only one implementation of a virtual package, it's selected automatically, otherwise
# the user is requested to select which one to use.

policy :rails, :roles => :app do
  requires :rails, :version => "3.2"
  requires :appserver
  requires :database
  requires :webserver
  requires :scm
end

# Deployment

# Configures sprinkle to use capistrano for delivery of commands to the remote machines (via
# the named 'deploy' recipe). Also configures 'source' installer defaults to put package gear
# in /usr/local

deployment do

  # mechanism for deployment
  delivery :capistrano do
    recipes 'deploy'
  end

  # source based package installer defaults
  source do
    prefix   '/usr/local'           # where all source packages will be configured to install
    archives '/usr/local/sources'   # where all source packages will be downloaded to
    builds   '/usr/local/build'     # where all source packages will be built
  end

end
```

Please see the examples directory for more complete examples of Sprinkle deployment scripts, and 
also the [Passenger Stack github page](http://github.com/benschwarz/passenger-stack) and [video by 
Ben Schwarz](http://www.vimeo.com/2888665).
