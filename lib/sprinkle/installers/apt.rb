module Sprinkle
  module Installers
    # = Apt Package Installer
    #
    # The Apt package installer uses the +apt-get+ command to install
    # packages. The apt installer has only one option which can be
    # modified which is the +dependencies_only+ option. When this is
    # set to true, the installer uses +build-dep+ instead of +install+
    # to only build the dependencies.
    # 
    # == Example Usage
    #
    # First, a simple installation of the magic_beans package:
    #
    #   package :magic_beans do
    #     description "Beans beans they're good for your heart..."
    #     apt 'magic_beans_package'
    #   end
    #
    # Second, only build the magic_beans dependencies:
    #
    #   package :magic_beans_depends do
    #     apt 'magic_beans_package' { dependencies_only true }
    #   end
    #
    # As you can see, setting options is as simple as creating a
    # block and calling the option as a method with the value as 
    # its parameter.
    class Apt < Installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, *packages, &block) #:nodoc:
        packages.flatten!
        
        options = { :dependencies_only => false }
        options.update(packages.pop) if packages.last.is_a?(Hash)
        
        super parent, options, &block
        
        @packages = packages
      end

      protected

        def install_commands #:nodoc:
          command = @options[:dependencies_only] ? 'build-dep' : 'install'
          "env DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive apt-get --force-yes -qyu #{command} #{@packages.join(' ')}"
        end

    end
  end
end
