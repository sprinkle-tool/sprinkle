Content also available online at: http://redartisan.com/2008/5/27/sprinkle-intro

### Sprinkle some Powder!

Provisioning a brand new server or VPS slice can be quite tricky, tedious and time consuming, particularly if done manually with changing software versions and configurations. 

In the Rails world, most of us are using virtual private servers which are instantiated from base operating system images, it takes only a few minutes to create a slice, however installing the rest of your server's stack, be it Rails, Merb or another framework is where the work begins. Provisioning in this sense, is installing all software required post operating system install.

Sprinkle is a new prototype tool that you can use to provision your servers/slices. Its declarative policy/state based approach for specifying how a remote system should be provisioned with intelligent logic to support dependencies, multiple installer types and remote installation is really compelling.

Several free and commercially available tools already exist to help automate the installation of software however most fall into two styles of design:

  1 - Task based, where the tool issues a list of commands to run on the remote system, either remotely via a network connection or smart client.  
  2 - Policy/state based, where the tool determines what needs to be run on the remote system by examining its current and final state.

Task based solutions are usually quite easy and fast to get up and running, but can be problematic as the user has to define all of the commands manually (not to mention get them right with testing). Policy/state based solutions have much more intelligence about how to modify and adapt the remote system, but often require specialized software to run remotely.

Sprinkle is a prototype tool I've been working on recently in this space that merges both concepts together, using a Ruby domain specific language to declaratively describe the state of the remote system. Using Sprinkle, provisioning your brand new remote server or slice can be automated using pre-defined and/or customized scripts from a single machine at your fingertips.

Sprinkle reads a script that defines a set of packages, a set of policies that define what packages should be installed on what roles of target machines, and a deployment section that defines the delivery mechanism for communicating with remote machines, and any default settings.

Packages can have relationships between each other to support dependencies. Virtual packages are also supported allowing you to define a role that a package (or multiple) fulfills, with the user or Sprinkle selecting which concrete package should be used at runtime.

Packages can also support arbitrary installer types, allowing you to install packages from source, gems, apt, or any other installer you'd like to employ. Installer types know what commands need to be issued to install packages, so all that needs to be specified in a script is the installer type and metadata about the package itself.

In essence, Sprinkle is about defining a domain specific meta-language for describing and processing the installation of software.

### Example Sprinkle Script

Here's an example Sprinkle deployment script, annotated to explain each section:

<filter:jscode lang="ruby">
# Annotated Example Sprinkle Rails deployment script
#
# This is an example Sprinkle script configured to install Rails from Gems, Apache, Ruby and
# Sphinx from source, and MySQL from APT on an Ubuntu system.
#
# Installation is configured to run via capistrano (and an accompanying deploy.rb recipe script).
# Source based packages are downloaded and built into /usr/local on the remote system.
#
# A sprinkle script is separated into 3 different sections. Packages, policies and deployment:


# Packages (separate files for brevity)
#
#  Defines the world of packages as we know it. Each package has a name and
#  set of metadata including its installer type (eg. apt, source, gem, etc). Packages can have
#  relationships to each other via dependencies.

require 'packages/essential'
require 'packages/rails'
require 'packages/database'
require 'packages/server'
require 'packages/search'


# Policies
#
#  Names a group of packages (optionally with versions) that apply to a particular set of roles:
#
#   Associates the rails policy to the application servers. Contains rails, and surrounding
#   packages. Note, appserver, database, webserver and search are all virtual packages defined above.
#   If there's only one implementation of a virtual package, it's selected automatically, otherwise
#   the user is requested to select which one to use.

policy :rails, :roles => :app do
  requires :rails, :version => '2.0.2'
  requires :appserver
  requires :database
  requires :webserver
  requires :search
end


# Deployment
#
#  Defines script wide settings such as a delivery mechanism for executing commands on the target
#  system (eg. capistrano), and installer defaults (eg. build locations, etc):
#
#   Configures sprinkle to use capistrano for delivery of commands to the remote machines (via
#   the named 'deploy' recipe). Also configures 'source' installer defaults to put package gear
#   in /usr/local

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

# End of script, given the above information, Spinkle will apply the defined policy on all roles using the
# deployment settings specified.
</filter:jscode>

Given such a script, Sprinkle will apply the defined policy __rails__ on the target machines identified by the role __app__, where the policy rails is composed of packages for the rails gem itself, an application server, webserver, search daemon, and the ruby runtime.

Currently, Sprinkle uses [Capistrano](http://www.capify.org) internally for communicating with remote systems, however this is pluggable as well, allowing for just about any concievable delivery mechanism in the future. The deployment section above identifies Capistrano as the delivery mechanism, specifying a local deploy.rb script that defines what roles are available, and what machines are defined within those roles.

This particular script breaks the package section up into multiple files, here are some of the actual package definitions (complete example available [here](http://github.com/crafterm/sprinkle/tree/master/examples/rails)):

<filter:jscode lang="ruby">
package :ruby do
  description 'Ruby Virtual Machine'
  version '1.8.6'
  source "ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-#{version}-p111.tar.gz" # implicit :style => :gnu
  requires :ruby_dependencies
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

package :sphinx, :provides => :search do
  description 'MySQL full text search engine'
  version '0.9.8-rc2'
  source "http://www.sphinxsearch.com/downloads/sphinx-#{version}.tar.gz"
  requires :mysql_dev
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
</filter:jscode>

Each package includes a description, optional version, optional list of dependencies and an installer type (also optional allowing for meta-packages).

Source installers are particularly intelligent and will download, configure and install source archives from a remote location directly on the target machine. They assume GNU style source archives by default (ie. tar.gz/tar.bz2 compressed archives, configure script and make, make install style semantics), however are completely customziable to support any arbitrary build style (rubygems for example does this above), with pre and post commands.

The Apache installer for example, specifies a few extra source installer options such as a set of _--enable_ options, an alternate installation prefix and a series of post installation commands to be executed.

With this example configuration, lets take a look at actually using Sprinkle to provision a remote server.

### Usage

Sprinkle supports several command line options:

    Usage
    =====

    $> sprinkle [options]

    Options are:

      -s, --script=PATH                Path to a sprinkle script to run
      -t, --test                       Process but don't perform any actions
      -v, --verbose                    Verbose output
      -c, --cloud                      Show powder cloud, ie. package hierarchy and installation order
      -h, --help                       Show this help message.

where you can name the script to be procesed, enable testing mode or verbose output, and/or examine the cloud of packages and operations that will be performed.

### Viewing the powder cloud!

Sprinkle calculates all operations to be performed on remote servers upfront which is nice, as it allows you to inspect what modifications will be made to the system before any are actually performed. Lets inspect the powder (ie. package) cloud for the above script:

    $> sprinkle -c -t -s rails.rb
    --> Cloud hierarchy for policy rails

    Policy rails requires package rails
            Package rails requires rubygems
                    Package rubygems requires build_essential
                    Package rubygems requires ruby
                            Package ruby requires build_essential
                            Package ruby requires ruby_dependencies

    Policy rails requires package appserver
    Selecting mongrel_cluster for virtual package appserver
            Package mongrel_cluster requires rubygems
                    Package rubygems requires build_essential
                    Package rubygems requires ruby
                            Package ruby requires build_essential
                            Package ruby requires ruby_dependencies
            Package mongrel_cluster requires mongrel
                    Package mongrel requires rubygems
                            Package rubygems requires build_essential
                            Package rubygems requires ruby
                                    Package ruby requires build_essential
                                    Package ruby requires ruby_dependencies

    Policy rails requires package database
    Selecting mysql for virtual package database

    Policy rails requires package webserver
    Selecting apache for virtual package webserver
            Package apache requires build_essential
            Package apache requires apache_dependencies

    Policy rails requires package search
    Selecting sphinx for virtual package search
            Package sphinx requires build_essential
            Package sphinx requires mysql_dev

    --> Normalized installation order for all packages: build_essential, ruby_dependencies, ruby, rubygems, rails, mongrel, mongrel_cluster, mysql, apache_dependencies, apache, mysql_dev, sphinx

-c indicates that Sprinkle should print the powder cloud (ie. the output above)  
-t indicates that we're operating in test mode, so we won't actually perform any remote commands  
-s identifies the Sprinkle script that should be processed  

Above we can see that the policy __rails__ required packages __rails__, __appserver__, __database__, __webserver__ and __search__. 

Note that all of these packages bar __rails__ are actually _virtual_ packages, so Sprinkle has selected an appropriate implementation of each virtual package automatically based on the supplied package definitions. If more than one package provided an implementation of a virtual package, then the user would be given the opportunity to select which one they prefer.

Under each package is a textual representation of that package's dependency tree, including all sub-dependencies, etc. Dependencies are packages that need to be installed first before a higher level package can be installed. 

You'll notice that several packages have the same dependencies, eg. both _rails_ and _mongrel_ require _ruby_, which has its own dependencies as well. Sprinkle will install all packages in reverse dependency order so that lower level dependencies are installed before higher level packages, and it will also normalize the final package list to remove duplicates so that packages aren't installed multiple times unnecessarily. This is the final line in the output above which lists the actual packages to be installed and order of installation.

### Provisioning a remote system

To actually provision a remote server we simply remove the _testing_ (and if desired _cloud_) flags from the command issued above and Sprinkle will process the configuration and provision the remote system. Note for the moment, you'll need to ensure that your SSH keys are appropriately installed on the remote server under a user that has enough privileges to install software (generally the root user):

    $> sprinkle -s rails.rb
    --> Installing build_essential for roles: app
    --> Installing ruby_dependencies for roles: app
    --> Installing ruby for roles: app
    --> Installing rubygems for roles: app
    --> Installing rails for roles: app
    --> Installing mongrel for roles: app
    --> Installing mongrel_cluster for roles: app
    --> Installing mysql for roles: app
    --> Installing apache_dependencies for roles: app
    --> Installing apache for roles: app
    --> Installing mysql_dev for roles: app
    --> Installing sphinx for roles: app

(its also possible to put the _#!/usr/bin/env sprinkle -c_ line at the top of a sprinkle script and make it executable).

After the command is finished, all of the requested software will have been applied on your target system.

If you'd like to see more action printed as commands are run, specify the --verbose (-v) flag. Internally, Capistrano tasks are dynamically defined and executed at runtime for each package's installation, using a Capistrano configuration file to identify the actual roles and hostnames associated with those roles to communicate with. The verbose option will display Capistrano activity in addition to the usual Sprinkle output.

An extra benefit of leveraging Capistrano is that you can actually provision multiple servers/slices simultaneously and in parallel if desired.

### I want!

If you're interested in downloading and experimenting with Sprinkle, you can clone and/or watch the [project](http://github.com/crafterm/sprinkle) at GitHub, or download it from GitHub's gem server using:

    $> sudo gem install crafterm-sprinkle --source http://gems.github.com/

The official Rubyforge gem server will also be updated over the coming days as well. If you download the source, you can create a gem package for installation by:

    $> rake package
    $> sudo gem install -l pkg/sprinkle-0.1.0

There are also specs with a decent amount of coverage over the code base that you can run as well:

    $> rake spec

### Prerequsites

Installing the Sprinkle gem will also install all pre-requsite gems such as _activesupport_, _highline_ and _capistrano_. The only other pre-requisite is that you have SSH connectivity to the remote system you wish to provision, preferably with SSH keys in place to prevent passwords being asked for.

### Finally

Sprinkle is a young project and while operational still in development, with several limitations. Currently, only Ubuntu/Debian has been tested as a target deployment platform, operating system abstraction and other platforms will be tested and supported in the future, along with several new features that are in the pipeline.

I'm most certainly open to ideas, suggestions and thoughts about how Sprinkle can be improved and generally made better for the community, and I really welcome any bug reports, patches and suggestions. Please feel free to contact me with any comments at all.

### Special Thanks!

Several people have been really helpful during the development of Sprinkle. In particular I'd like to thank [Ben Schwarz](http://germanforblack.com/) and [Pete Yandell](http://notahat.com/) for their initial feedback and help after my first demos. I'd also really like to thank Matthew and Jared from [Slicehost](http://www.slicehost.com/) for their help and support as well.
