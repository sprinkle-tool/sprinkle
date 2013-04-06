module Sprinkle
  module Installers
    # = Zypper Installer
    #
    # Zypper is a command-line interface to ZYpp system management library.
    # It mostly be used on Suse or OpenSuse.
    # 
    # == Example Usage
    #
    # Installing the magic_beans package via Zypper. Its all the craze these days.
    #
    #   package :magic_beans do
    #     zypper 'magic_beans'
    #   end
    #
    # You may also specify multiple packages as an argument list or array:
    #
    #   package :magic_beans do
    #     zypper "magic_beans", "magic_sauce"
    #   end
    class Zypper < PackageInstaller

      protected

      def install_commands #:nodoc:
        "zypper -n install -l -R #{@packages.join(' ')}"
      end
    end
  end
end
