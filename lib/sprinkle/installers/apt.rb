module Sprinkle
  module Installers
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
    #     apt 'magic_beans_package'
    #     verify { has_apt 'magic_beans_package' }
    #   end
    #
    # Second, only build the magic_beans dependencies:
    #
    #   package :magic_beans_depends do
    #     apt 'magic_beans_package' do
    #       dependencies_only true 
    #     end
    #   end
    #
    # As you can see, setting options is as simple as creating a
    # block and calling the option as a method with the value as 
    # its parameter.
    class Apt < PackageInstaller
      def initialize(parent, *packages, &block) #:nodoc:
        super parent, *packages, &block
        @options.reverse_merge!(:dependencies_only => false)
      end

      auto_api
      
      verify_api do
        def has_apt(package)
          @commands << "dpkg --status #{package} | grep \"ok installed\""
        end
      end

      protected

        def install_commands #:nodoc:
          command = @options[:dependencies_only] ? 'build-dep' : 'install'
          noninteractive = "env DEBCONF_TERSE='yes' DEBIAN_PRIORITY='critical' DEBIAN_FRONTEND=noninteractive"
          "#{noninteractive} #{sudo_cmd}apt-get --force-yes -qyu #{command} #{@packages.join(' ')}"
        end

    end
  end
end
