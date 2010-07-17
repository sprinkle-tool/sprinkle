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
    # You may also specify multiple packages as an array:
    #
    #   package :magic_beans do
    #     zypper %w(magic_beans magic_sauce)
    #   end
    #
    # or an argument list:
    #
    #   package :magic_beans do
    #     zypper "magic_beans", "magic_sauce"
    #   end
    class Zypper < Installer
      attr_accessor :packages #:nodoc:

      def initialize(parent, *packages, &block) #:nodoc:
        packages.flatten!
        super parent, &block
        @packages = packages
      end

      protected

      def install_commands #:nodoc:
        "zypper -n install -l -R #{@packages.join(' ')}"
      end
    end
  end
end
